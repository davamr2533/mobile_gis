import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gis_mobile/colors/app_colors.dart';

class HistoryCard extends StatelessWidget {
  final String id;
  final String location;
  final String status;
  final Color sideColor;

  const HistoryCard({
    super.key,
    required this.id,
    required this.location,
    required this.status,
    this.sideColor = AppColors.thirdBase,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        // Kartu utama
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Kolom kiri (ID dan lokasi)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "GIS-ID-$id",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSoftGray,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Status kanan
                Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPending,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Garis warna di sisi kiri
        Container(
          width: 10,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            color: sideColor,
          ),
        ),
      ],
    );
  }
}
