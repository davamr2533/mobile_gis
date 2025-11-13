import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gis_mobile/api/models/ont_model.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DetailOntCard extends StatelessWidget {
  final OntModel ont;

  const DetailOntCard({
    super.key,
    required this.ont,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      if (ont.fotoOnt1 != null && ont.fotoOnt1!.isNotEmpty)
        "http://202.169.224.27:8081${ont.fotoOnt1}",
      if (ont.fotoOnt2 != null && ont.fotoOnt2!.isNotEmpty)
        "http://202.169.224.27:8081${ont.fotoOnt2}",
      if (ont.fotoOnt3 != null && ont.fotoOnt3!.isNotEmpty)
        "http://202.169.224.27:8081${ont.fotoOnt3}",
    ];


    final pageController = PageController();

    // Konversi string latitude & longitude ke double
    final double? lat = double.tryParse(ont.latitude);
    final double? lng = double.tryParse(ont.longitude);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (images.isNotEmpty)
                Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: images.length,
                        itemBuilder: (context, i) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              images[i],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.fifthBase,
                                child: const Icon(Icons.broken_image,
                                    color: Colors.grey, size: 50),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SmoothPageIndicator(
                      controller: pageController,
                      count: images.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        spacing: 6,
                        activeDotColor: AppColors.thirdBase,
                        dotColor: Colors.grey.shade300,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.fifthBase,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey, size: 50),
                ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: Text(
                  ont.createdAt,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              _buildDetail("Nomor ONT", "GIS-ID-${ont.nomorOnt}"),
              _buildDetail("Provinsi", ont.area),
              _buildDetail("Petugas", ont.namaPetugas),
              _buildDetail("Deskripsi", ont.deskripsiRumah),

              const Divider(),
              const SizedBox(height: 8),

              //Map Preview
              if (lat != null && lng != null)
                _mapPreview(lat, lng)
              else
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Lokasi tidak valid",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),

              const SizedBox(height: 8),

              _coordRow("Latitude", ont.latitude),
              _coordRow("Longitude", ont.longitude),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.thirdBase,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    "Kembali",
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

  Widget _mapPreview(double lat, double lng) {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.hardEdge,
      child: AbsorbPointer(
        absorbing: true,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(lat, lng),
            initialZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.gis_mobile',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(lat, lng),
                  width: 50,
                  height: 50,
                  child: const Icon(Icons.location_pin,
                      color: Colors.red, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String? value) {
    return Container(
      width: double.infinity,
      height: 45,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.fifthBase,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value ?? "-",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textDarkGray,
        ),
      ),
    );
  }

  Widget _coordRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
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
                value ?? "-",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
