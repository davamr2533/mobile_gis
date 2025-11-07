import 'package:flutter/material.dart';
import 'package:gis_mobile/api/services/get/get_notifikasi.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:gis_mobile/widgets/cards/notification_card.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.firstBase,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(50),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,

            title: Text(
              "Notification",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),

      body: FutureBuilder(
          future: NotifikasiService.fetchDataNotifikasi(),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            }

            final notifikasi = snapshot.data!;

            return Padding(
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
                child: ListView.builder(
                  itemCount: notifikasi.length,
                    itemBuilder: (context, index)  {
                      final item = notifikasi[index];
                      return NotificationCard(notif: item);
                    }
                )
            );
          }
      )


    );
  }
}
