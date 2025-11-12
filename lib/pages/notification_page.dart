import 'package:flutter/material.dart';
import 'package:gis_mobile/api/services/get/get_notifikasi.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:gis_mobile/widgets/cards/notification_card.dart';
import 'package:gis_mobile/widgets/pop_up/loading.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<dynamic>> _notifikasiFuture;

  @override
  void initState() {
    super.initState();
    _notifikasiFuture = NotifikasiService.fetchDataNotifikasi();
  }

  Future<void> _refreshNotifikasi() async {
    setState(() {
      _notifikasiFuture = NotifikasiService.fetchDataNotifikasi();
    });
    await _notifikasiFuture;
  }

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
      body: FutureBuilder<List<dynamic>>(
        future: _notifikasiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: AppWidget().loadingWidget());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,

              ),
            );
          }

          final notifikasi = snapshot.data!;

          // Sort terbaru di atas
          notifikasi.sort((a, b) {
            return DateTime.parse(b.createdAt)
                .compareTo(DateTime.parse(a.createdAt));
          });

          return RefreshIndicator(
            onRefresh: _refreshNotifikasi,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
              itemCount: notifikasi.length + 1, // ✅ tambah 1 item di atas
              itemBuilder: (context, index) {


                if (index == 0) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.pink.shade200),
                    ),
                    child: Text(
                      "Notifikasi akan hilang secara otomatis dalam 30 hari.",
                      style: GoogleFonts.poppins(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  );
                }

                // ✅ sisanya = notifikasi asli
                final item = notifikasi[index - 1]; // karena index 0 untuk info
                return NotificationCard(notif: item);
              },
            ),
          );
        },
      ),
    );
  }
}
