import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:gis_mobile/api/get_provinsi.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:gis_mobile/pages/map_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


Future<void> showFormOnt(BuildContext context) {

  double? selectedLatitude;
  double? selectedLongitude;
  List<XFile> selectedImages = [];


  return showDialog(
    context: context,
    useSafeArea: true,
    builder: (BuildContext context) {
      String? selectedProv;
      List<String> dialogProvinsi = [];

      return StatefulBuilder(
        builder: (context, setStateDialog) {




          // ambil data provinsi saat dialog muncul
          Future<void> loadProvinsi() async {
            final provinsi = await getProvinsi();
            setStateDialog(() {
              dialogProvinsi = provinsi;
            });
          }

          WidgetsBinding.instance
              .addPostFrameCallback((_) {
            if (dialogProvinsi.isEmpty) {
              loadProvinsi();
            }
          });

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: SizedBox(
              width: 350,
              height: 720,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // === HEADER ===
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          Text(
                            "Form ONT",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color:
                              AppColors.firstBase,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // === ICON ADD PHOTO ===
                      Center(
                        child: GestureDetector(
                          onTap: () async {
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
                                        leading: Icon(Icons.camera_alt, color: Colors.black87),
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
                                            setStateDialog(() {
                                              if (selectedImages.length < 3) {
                                                selectedImages.add(photo);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text("Maksimal 3 foto aja ya 😄"),
                                                  ),
                                                );
                                              }
                                            });
                                          }
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.photo_library, color: Colors.black87),
                                        title: Text(
                                          "Pilih dari Galeri",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        onTap: () async {
                                          Navigator.pop(context); // tutup sheet

                                          final ImagePicker picker = ImagePicker();
                                          final List<XFile> images = await picker.pickMultiImage(
                                            imageQuality: 80,
                                          );

                                          if (images.isNotEmpty) {
                                            setStateDialog(() {
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
                                              onTap: () {
                                                setStateDialog(() {
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
                        padding:
                        const EdgeInsets.symmetric(
                            horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.fifthBase,
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child:
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedProv,
                            hint: Text(
                              dialogProvinsi.isEmpty
                                  ? "Loading provinsi..."
                                  : "Pilih Provinsi",
                              style: GoogleFonts.poppins(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13
                              ),
                            ),
                            isExpanded: true,
                            icon: const Icon(
                              Icons
                                  .arrow_drop_down_rounded,
                              color: Colors.black54,
                            ),
                            items: dialogProvinsi
                                .map((prov) {
                              return DropdownMenuItem<
                                  String>(
                                value: prov,
                                child: Text(
                                  prov,
                                  style: GoogleFonts
                                      .poppins(
                                    fontWeight:
                                    FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedProv = value;
                              });
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      _buildTextField("Nama Petugas"),

                      SizedBox(height: 12),

                      _buildTextField(
                          "Deskripsi lokasi rumah",
                          maxLines: 2
                      ),

                      SizedBox(height: 8),

                      Divider(color: AppColors.textSoftGray,thickness: 1),

                      SizedBox(height: 8),

                      Text(
                        "Koordinat Lokasi",
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black
                        ),
                      ),

                      SizedBox(height: 8),

                      //Map Preview
                      if (selectedLatitude != null && selectedLongitude != null)
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.textSoftGray, width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AbsorbPointer(
                              absorbing: true, // Nonaktifkan interaksi
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

                      SizedBox(height: 8),

                      FilledButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MapPage()),
                          );

                          if (result != null) {
                            // result adalah LatLng (latitude & longitude)
                            setStateDialog(() {
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
                          padding: EdgeInsets.all(12),
                          minimumSize: Size(double.infinity, 40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_location_alt,
                              size: 20,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Atur Koordinat Lokasi",
                              style: GoogleFonts.poppins(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                                fontSize: 13
                              ),
                            ),
                          ],
                        ),
                      ),




                      SizedBox(height: 12),

                      Row(
                        children: [
                          Text(
                            "Latitude",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),

                          SizedBox(width: 20),

                          Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 8),
                                alignment: Alignment.centerLeft,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.textSoftGray,
                                      width: 1
                                  ),
                                ),
                                child: Text(
                                 selectedLatitude != null ? selectedLatitude!.toStringAsFixed(6) : "-",
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              )
                          )
                        ],
                      ),

                      SizedBox(height: 8),

                      Row(
                        children: [
                          Text(
                            "Longitude",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),

                          SizedBox(width: 8),

                          Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 8),
                                alignment: Alignment.centerLeft,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.textSoftGray,
                                      width: 1
                                  ),
                                ),
                                child: Text(
                                  selectedLongitude != null ? selectedLongitude!.toStringAsFixed(6) : "-",
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              )
                          )
                        ],
                      ),





                      SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            AppColors.thirdBase,
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                  50),
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
            ),
          );
        },
      );
    },
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