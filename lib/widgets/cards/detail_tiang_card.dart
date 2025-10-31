import 'package:flutter/material.dart';
import 'package:gis_mobile/api/models/tiang_model.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DetailTiangCard extends StatelessWidget {
  final TiangModel tiang;

  const DetailTiangCard({
    super.key,
    required this.tiang,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      if (tiang.fotoTiang1.isNotEmpty)
        "http://202.169.231.66:82${tiang.fotoTiang1}",
      if (tiang.fotoTiang2.isNotEmpty)
        "http://202.169.231.66:82${tiang.fotoTiang2}",
      if (tiang.fotoTiang2.isNotEmpty)
        "http://202.169.231.66:82${tiang.fotoTiang3}",
    ];

    final pageController = PageController();

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
                  tiang.createdAt,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              _buildDetail("Nomor Tiang", "GIS-ID-${tiang.nomorTiang}"),
              _buildDetail("Provinsi", tiang.area),
              _buildDetail("Petugas", tiang.namaPetugas),
              _buildDetail("Deskripsi", tiang.deskripsiTiang),

              const Divider(),
              const SizedBox(height: 8),

              _coordRow("Latitude", tiang.latitude),
              _coordRow("Longitude", tiang.longitude),

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












