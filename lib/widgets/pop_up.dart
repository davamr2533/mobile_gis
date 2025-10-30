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


//class untuk pop up konfirmasi hapus
class PopUpDelete extends StatelessWidget {
  final VoidCallback onConfirm;

  const PopUpDelete({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20)
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 80),
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
                      Icons.delete_forever_rounded,
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
                "Hapus",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Center(
              child: Text(
                "Anda yakin ingin menghapus?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textDarkGray,
                ),
              ),
            ),

            SizedBox(height: 8),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tombol Batal
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondBase,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 0,
                  ),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Tombol Hapus
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();


                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.thirdBase,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 0,
                  ),
                  child: Text(
                    'Hapus',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

//class untuk pop up success
class PopUpDeleteSuccess extends StatelessWidget {
  const PopUpDeleteSuccess({super.key});

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
                "Data berhasil dihapus!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textDarkGray,
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.softGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  "Tutup",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),




          ],
        ),
      ),
    );
  }
}




