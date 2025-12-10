import 'package:flutter/material.dart';
import 'package:gis_mobile/api/models/notifikasi_model.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationCard extends StatelessWidget {
  final NotifikasiModel notif;

  const NotificationCard({
    super.key,
    required this.notif,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // === CARD NOTIFIKASI ===
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian atas: judul + status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.tipeNotifikasi,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),

                        Text(
                          "Data ${notif.jenis} berhasil dikirim",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      child: Text(
                        notif.status,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Divider(color: AppColors.softGrayNewAmikom, thickness: 1),

                const SizedBox(height: 4),

                // Bagian bawah: kode + tanggal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notif.nomor,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      notif.createdAt.split(' ')[0],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),
      ],
    );
  }
}
