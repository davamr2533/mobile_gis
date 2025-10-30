import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:gis_mobile/pages/main_page.dart';
import 'package:gis_mobile/widgets/pop_up.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gis_mobile/api/get_provinsi.dart';
import 'package:gis_mobile/pages/map_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

  @override
  void initState() {
    super.initState();
    loadProvinsi();
  }

  Future<void> loadProvinsi() async {
    final provinsi = await getProvinsi();
    setState(() {
      dialogProvinsi = provinsi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Form ONT",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.firstBase,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === ICON ADD PHOTO ===
              Center(
                child: GestureDetector(
                  onTap: () async {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) {
                        return SafeArea(
                          child: Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt,
                                    color: Colors.black87),
                                title: Text(
                                  "Ambil Foto dari Kamera",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onTap: () async {
                                  Navigator.pop(context); // tutup sheet

                                  final ImagePicker picker = ImagePicker();
                                  final XFile? photo = await picker.pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: 80,
                                  );

                                  if (photo != null) {
                                    setState(() {
                                      if (selectedImages.length < 3) {
                                        selectedImages.add(photo);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                            Text("Maksimal 3 foto aja ya 😄"),
                                          ),
                                        );
                                      }
                                    });
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library,
                                    color: Colors.black87),
                                title: Text(
                                  "Pilih dari Galeri",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onTap: () async {
                                  Navigator.pop(context); // tutup sheet

                                  final ImagePicker picker = ImagePicker();
                                  final List<XFile> images =
                                  await picker.pickMultiImage(
                                    imageQuality: 80,
                                  );

                                  if (images.isNotEmpty) {
                                    setState(() {
                                      if (images.length > 3) {
                                        selectedImages =
                                            images.take(3).toList();
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
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.fourthBase,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tambahkan foto rumah",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Foto : ${selectedImages.length}/3",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSoftGray,
                        ),
                      ),
                      if (selectedImages.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            children:
                            selectedImages.asMap().entries.map((entry) {
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
                                      onTap: () {
                                        setState(() {
                                          selectedImages.removeAt(i);
                                        });
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
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
              _buildTextField("Nomor ONT"),
              const SizedBox(height: 12),

              // === DROPDOWN PROVINSI ===
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
                      dialogProvinsi.isEmpty
                          ? "Loading provinsi..."
                          : "Pilih Provinsi",
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    isExpanded: true,
                    icon: const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.black54,
                    ),
                    items: dialogProvinsi.map((prov) {
                      return DropdownMenuItem<String>(
                        value: prov,
                        child: Text(
                          prov,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProv = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),
              _buildTextField("Nama Petugas"),
              const SizedBox(height: 12),
              _buildTextField("Deskripsi lokasi rumah", maxLines: 2),
              const SizedBox(height: 8),
              Divider(color: AppColors.textSoftGray, thickness: 1),
              const SizedBox(height: 8),

              Text(
                "Koordinat Lokasi",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Map Preview
              if (selectedLatitude != null && selectedLongitude != null)
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.textSoftGray, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AbsorbPointer(
                      absorbing: true,
                      child: FlutterMap(
                        mapController: MapController(),
                        options: MapOptions(
                          initialCenter:
                          LatLng(selectedLatitude!, selectedLongitude!),
                          initialZoom: 16,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.gis_mobile',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(
                                    selectedLatitude!, selectedLongitude!),
                                width: 50,
                                height: 50,
                                rotate: true,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              FilledButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapPage()),
                  );

                  if (result != null) {
                    setState(() {
                      selectedLatitude = result.latitude;
                      selectedLongitude = result.longitude;
                    });
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.fifthBase,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  minimumSize: const Size(double.infinity, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_location_alt,
                      size: 20,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Atur Koordinat Lokasi",
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Text(
                    "Latitude",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 8),
                      alignment: Alignment.centerLeft,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.textSoftGray, width: 1),
                      ),
                      child: Text(
                        selectedLatitude != null
                            ? selectedLatitude!.toStringAsFixed(6)
                            : "-",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Text(
                    "Longitude",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 8),
                      alignment: Alignment.centerLeft,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.textSoftGray, width: 1),
                      ),
                      child: Text(
                        selectedLongitude != null
                            ? selectedLongitude!.toStringAsFixed(6)
                            : "-",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Pop Up sesuai koneksi
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const PopUpSuccess(),
                    );

                    Future.delayed(const Duration(seconds: 2), () {
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MainPage(),
                          ),
                        );
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.thirdBase,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    "Kirim",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Colors.black54,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        filled: true,
        fillColor: AppColors.fifthBase,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    );
  }
}
