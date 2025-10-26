import 'package:flutter/material.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';


//class untuk pop up success
class PopUpSuccess extends StatelessWidget {
  const PopUpSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(20)
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 100),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.softGrayNewAmikom,
                  borderRadius: BorderRadiusGeometry.circular(100),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadiusGeometry.circular(100),
                      ),
                    ),

                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.softGreen,
                      size: 75,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "Success!",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Center(
              child: Text(
                "Data berhasil dikirim!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textDarkGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//class untuk pop up ke draft
class PopUpDraft extends StatelessWidget {
  const PopUpDraft({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20)
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 100),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.softGrayNewAmikom,
                  borderRadius: BorderRadiusGeometry.circular(100),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadiusGeometry.circular(100),
                      ),
                    ),

                    Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "Offline!",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Center(
              child: Text(
                "Data belum terkirim, disimpan dalam draft",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textDarkGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}