import 'package:flutter/material.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class TiangTabContent extends StatelessWidget {
  const TiangTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Riwayat tiang kosong",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSoftGray,
        ),
      ),
    );
  }
}