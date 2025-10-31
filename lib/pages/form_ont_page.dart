import 'dart:io';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:gis_mobile/pages/main_page.dart';
import 'package:gis_mobile/widgets/pop_up/pop_up.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gis_mobile/api/services/get_provinsi.dart';
import 'package:gis_mobile/pages/map_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormOntPage extends StatefulWidget {
  const FormOntPage({super.key});

  @override
  State<FormOntPage> createState() => _FormOntPageState();
}

class _FormOntPageState extends State<FormOntPage> {
  double? selectedLatitude;
  double? selectedLongitude;
  List<XFile> selectedImages = [];
  String? selectedProv;
  List<String> dialogProvinsi = [];
  bool isOnline = false;

  final TextEditingController _ontController = TextEditingController();
  final TextEditingController _petugasController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProvinsi();
    checkConnection();

    // pantau koneksi real-time
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      final hasNetwork = await _hasNetworkConnection(results);
      if (mounted) setState(() => isOnline = hasNetwork);
    });
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

  // === Ambil data provinsi ===
  Future<void> loadProvinsi() async {
    final provinsi = await getProvinsi();
    setState(() => dialogProvinsi = provinsi);
  }

  // === Simpan draft ke SharedPreferences ===
  Future<List<Map<String, dynamic>>> _readDraftsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ont_drafts');
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return List<Map<String, dynamic>>.from(list);
  }

  Future<void> _saveDraftToStorage(Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await _readDraftsFromStorage();
    drafts.add(draft);
    await prefs.setString('ont_drafts', jsonEncode(drafts));
  }

  // === Tombol Kirim ditekan ===
  Future<void> _onSubmit() async {
    if (_ontController.text.isEmpty ||
        _petugasController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        selectedProv == null ||
        selectedImages.isEmpty ||
        selectedLatitude == null ||
        selectedLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi semua data sebelum kirim ya 😄")),
      );
      return;
    }

    if (isOnline) {
      // === ONLINE ===
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const PopUpSuccess(),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainPage()));
        }
      });
    } else {
      // === OFFLINE: Simpan ke draft ===
      final List<String> base64Images = [];
      for (var img in selectedImages) {
        final bytes = await img.readAsBytes();
        base64Images.add(base64Encode(bytes));
      }

      final draft = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'ontNumber': _ontController.text.trim(),
        'provinsi': selectedProv,
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
        title: Text("Form ONT", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
                      Text("Tambahkan foto rumah", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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

              _buildTextField("Nomor ONT", controller: _ontController),
              const SizedBox(height: 12),

              // === PROVINSI ===
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.fifthBase,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedProv,
                    hint: Text(
                      dialogProvinsi.isEmpty ? "Loading provinsi..." : "Pilih Provinsi",
                      style: GoogleFonts.poppins(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                    isExpanded: true,
                    items: dialogProvinsi.map((prov) {
                      return DropdownMenuItem(value: prov, child: Text(prov, style: GoogleFonts.poppins()));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedProv = value),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildTextField("Nama Petugas", controller: _petugasController),
              const SizedBox(height: 12),

              _buildTextField("Deskripsi lokasi rumah", controller: _deskripsiController, maxLines: 2),
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
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.black87),
                title: Text("Ambil Foto dari Kamera", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                  if (photo != null && selectedImages.length < 3) {
                    setState(() => selectedImages.add(photo));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black87),
                title: Text("Pilih dari Galeri", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final List<XFile> images = await picker.pickMultiImage(imageQuality: 80);
                  if (images.isNotEmpty) {
                    setState(() {
                      if (images.length > 3) {
                        selectedImages = images.take(3).toList();
                      } else {
                        selectedImages = images;
                      }
                    });
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
