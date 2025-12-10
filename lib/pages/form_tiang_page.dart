import 'dart:io';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gis_mobile/api/models/wilayah_model.dart';
import 'package:gis_mobile/api/services/get/get_wilayah.dart';
import 'package:gis_mobile/api/services/post/post_data_tiang.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:gis_mobile/pages/main_page.dart';
import 'package:gis_mobile/widgets/pop_up/loading.dart';
import 'package:gis_mobile/widgets/pop_up/pop_up_draft.dart';
import 'package:gis_mobile/widgets/pop_up/pop_up_success.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gis_mobile/pages/map_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormTiangPage extends StatefulWidget {
  const FormTiangPage({super.key});

  @override
  State<FormTiangPage> createState() => _FormTiangPageState();
}

class _FormTiangPageState extends State<FormTiangPage> {
  double? selectedLatitude;
  double? selectedLongitude;
  List<XFile> selectedImages = [];
  WilayahModel? selectedWilayah;
  List<WilayahModel> listWilayah = [];
  bool isLoadingWilayah = true;
  bool isOnline = false;
  String getCurrentDatetime() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }

  final TextEditingController _tiangController = TextEditingController();
  final TextEditingController _petugasController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkConnection();
    loadWilayah();

    // pantau koneksi real-time
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      final hasNetwork = await _hasNetworkConnection(results);
      if (mounted) setState(() => isOnline = hasNetwork);
    });
  }

  //Ambil data area wilayah
  void loadWilayah() async {
    try {
      final data = await WilayahService.fetchDataWilayah();
      setState(() {
        listWilayah = data;
        isLoadingWilayah = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => isLoadingWilayah = false);
    }
  }

  // === Cek koneksi internet dengan ping ===
  Future<bool> _hasNetworkConnection(List<ConnectivityResult> results) async {
    if (results.isEmpty || results.first == ConnectivityResult.none) return false;
    try {
      final lookup = await InternetAddress.lookup('google.com');
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // === Cek koneksi saat pertama buka halaman ===
  Future<void> checkConnection() async {
    final results = await Connectivity().checkConnectivity();
    final hasNetwork = await _hasNetworkConnection(results);
    if (mounted) setState(() => isOnline = hasNetwork);
  }

  // === Simpan draft ke SharedPreferences ===
  Future<List<Map<String, dynamic>>> _readDraftsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('tiang_drafts');
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return List<Map<String, dynamic>>.from(list);
  }

  Future<void> _saveDraftToStorage(Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await _readDraftsFromStorage();
    drafts.add(draft);
    await prefs.setString('tiang_drafts', jsonEncode(drafts));
  }

  // === Tombol Kirim ditekan ===
  Future<void> _onSubmit() async {
    if (_tiangController.text.isEmpty ||
        _petugasController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        selectedWilayah == null ||
        selectedImages.isEmpty ||
        selectedLatitude == null ||
        selectedLongitude == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
              "Lengkapi semua data sebelum dikirim",
              style: GoogleFonts.poppins(),
            )
        ),
      );
      return;
    }

    if (isOnline) {
      // === ONLINE ===
      try {
        // Tampilkan indikator loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>  Center(child: AppWidget().loadingWidget()),
        );

        String? token = await FirebaseMessaging.instance.getToken();

        // List foto yang sudah dikompres
        List<File?> compressedFiles = [];

        for (var img in selectedImages) {
          final XFile compressedImg = await _compressIfNeeded(img);
          compressedFiles.add(File(compressedImg.path));
        }

        // Jika foto kurang dari 3 sisanya null
        while (compressedFiles.length < 3) {
          compressedFiles.add(null);
        }

        final File? foto1 = compressedFiles[0];
        final File? foto2 = compressedFiles[1];
        final File? foto3 = compressedFiles[2];

        // Kirim data ke server
        bool success = await TiangPostService.postDataTiang(
          nomorTiang: _tiangController.text.trim(),
          area: selectedWilayah!.name, // dari dropdown
          deskripsiTiang: _deskripsiController.text.trim(),
          fotoTiang1: foto1,
          fotoTiang2: foto2,
          fotoTiang3: foto3,
          latitude: selectedLatitude!.toString(),
          longitude: selectedLongitude!.toString(),
          namaPetugas: _petugasController.text.trim(),
          status: "Pending",
          statusNotifikasi: "Pending",
          tipeNotifikasi: "Submitted",
          fcmToken: token ?? "",
          datetime: getCurrentDatetime(),
          kodeTiang: _tiangController.text.trim()
        );

        // Tutup loading dialog
        Navigator.pop(context);

        if (success) {

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const PopUpSuccess(),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              Navigator.pop(context); // tutup popup
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainPage()));
            }
          });

        } else {

          try {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Gagal kirim data ke server")),
            );
          } catch (e, s) {
            print("ERROR CATCH: $e");
            print("STACKTRACE: $s");
          }

        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi error: $e")),
        );
      }

    } else {
      // === OFFLINE: Simpan ke draft ===

      // Tampilkan indikator loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>  Center(child: AppWidget().loadingWidget()),
      );

      try {
        final List<String> base64Images = [];

        for (var img in selectedImages) {
          final XFile compressedImg = await _compressIfNeeded(img);
          final bytes = await File(compressedImg.path).readAsBytes();
          base64Images.add(base64Encode(bytes));
        }

        final draft = {
          'id': DateTime.now().millisecondsSinceEpoch,
          'tiangNumber': _tiangController.text.trim(),
          'provinsi': selectedWilayah?.name,
          'petugas': _petugasController.text.trim(),
          'deskripsi': _deskripsiController.text.trim(),
          'latitude': selectedLatitude,
          'longitude': selectedLongitude,
          'images': base64Images,
          'createdAt': DateTime.now().toIso8601String(),
        };

        await _saveDraftToStorage(draft);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const PopUpDraft(),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.pop(context);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainPage()));
          }
        });

      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan draft: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Form Tiang", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.firstBase,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 8),

              // === FOTO ===
              Center(
                child: GestureDetector(
                  onTap: _pickImageOptions,
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.fourthBase,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(child: Icon(Icons.add_a_photo_outlined, size: 30)),
                      ),
                      const SizedBox(height: 8),
                      Text("Tambahkan foto tiang", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      Text(
                        "Foto : ${selectedImages.length}/3",
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSoftGray),
                      ),
                      if (selectedImages.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            children: selectedImages.asMap().entries.map((entry) {
                              final i = entry.key;
                              final img = entry.value;
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(img.path),
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () => setState(() => selectedImages.removeAt(i)),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // === PROVINSI ===
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.fifthBase,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<WilayahModel>(

                      value: selectedWilayah,
                      hint: Text(
                        "Pilih Provinsi",
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      isExpanded: true,
                      items: listWilayah.map((wil) {
                        return DropdownMenuItem(
                          value: wil,
                          child: Text(wil.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedWilayah = value;

                          // Otomatis isi prefix ONT
                          _tiangController.text = "${value?.kode}";

                          // Cursor otomatis pindah ke belakang
                          _tiangController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _tiangController.text.length),
                          );
                        });
                      },

                    )
                ),
              ),
              const SizedBox(height: 12),

              _buildTextField("Nomor Tiang", controller: _tiangController),
              const SizedBox(height: 12),

              _buildTextField("Nama Petugas", controller: _petugasController),
              const SizedBox(height: 12),

              _buildTextField("Deskripsi lokasi tiang", controller: _deskripsiController, maxLines: 2),
              const SizedBox(height: 8),
              Divider(color: AppColors.textSoftGray, thickness: 1),
              const SizedBox(height: 8),

              Text("Koordinat Lokasi", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              if (selectedLatitude != null && selectedLongitude != null)
                _mapPreview(),

              const SizedBox(height: 8),

              FilledButton(
                onPressed: _pickLocation,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.fifthBase,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(12),
                  minimumSize: const Size(double.infinity, 40),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_location_alt, size: 20, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text("Atur Koordinat Lokasi", style: GoogleFonts.poppins(color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _coordRow("Latitude", selectedLatitude),
              const SizedBox(height: 8),
              _coordRow("Longitude", selectedLongitude),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.thirdBase,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  child: Text("Kirim", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //fungsi untuk compress file ke 200kb
  Future<XFile> _compressIfNeeded(XFile file) async {
    final original = File(file.path);
    final size = await original.length();

    if (size <= 200 * 1024) return file;

    // Buat path output yang aman
    final dir = original.parent.path;
    final targetPath = '$dir/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

    int quality = 70;
    File? compressed;

    do {
      final result = await FlutterImageCompress.compressAndGetFile(
        original.path,
        targetPath,
        quality: quality,
      );
      compressed = result != null ? File(result.path) : null;
      quality -= 10;
    } while (compressed != null && await compressed.length() > 200 * 1024 && quality > 10);

    return XFile(compressed?.path ?? file.path);
  }

  //fungsi untuk mengambil gambar
  Future<void> _pickImageOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [

              //ambil foto dari kamera
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.black87),
                title: Text("Ambil Foto dari Kamera", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
                  if (photo != null && selectedImages.length < 3) {

                    setState(() => selectedImages.add(photo));
                  }
                },
              ),

              //ambil foto dari galeri
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black87),
                title: Text("Pilih dari Galeri", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final List<XFile> images = await picker.pickMultiImage(imageQuality: 100);
                  if (images.isNotEmpty) {

                    setState(() => selectedImages.addAll(images.take(3 - selectedImages.length)));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPage()));
    if (result != null) {
      setState(() {
        selectedLatitude = result.latitude;
        selectedLongitude = result.longitude;
      });
    }
  }

  Widget _coordRow(String label, double? value) {
    return Row(
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 8),
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.textSoftGray),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              value != null ? value.toStringAsFixed(6) : "-",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mapPreview() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textSoftGray),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AbsorbPointer(
          absorbing: true,
          child: FlutterMap(
            mapController: MapController(),
            options: MapOptions(
              initialCenter: LatLng(selectedLatitude!, selectedLongitude!),
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.gis_mobile',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(selectedLatitude!, selectedLongitude!),
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {TextEditingController? controller, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
        filled: true,
        fillColor: AppColors.fifthBase,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
    );
  }
}
