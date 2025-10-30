import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DraftTiangTab extends StatelessWidget {
  const DraftTiangTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Belum ada draft TIANG tersimpan",
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black54
        ),
      ),
    );
  }
}
