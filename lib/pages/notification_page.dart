import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gis_mobile/api/cubit/notifikasi_cubit.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:gis_mobile/widgets/cards/notification_card.dart';
import 'package:gis_mobile/widgets/pop_up/loading.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotifikasiCubit()..fetchNotifikasi(),
      child: Scaffold(
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

        // 💡 Bagian body pakai BlocBuilder
        body: BlocBuilder<NotifikasiCubit, NotifikasiState>(
          builder: (context, state) {
            // Loading state
            if (state is NotifikasiLoading) {
              return Center(child: AppWidget().loadingWidget());
            }

            // Error state
            if (state is NotifikasiError) {
              return Center(
                child: Text(
                  "Error: ${state.message}",
                  style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            // Empty state
            if (state is NotifikasiEmpty) {
              return Center(
                child: Text(
                  "Belum ada notifikasi.",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              );
            }

            // Loaded state
            if (state is NotifikasiLoaded) {
              final notifikasi = state.data;

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NotifikasiCubit>().fetchNotifikasi();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 30, left: 16, right: 16, bottom: 16),
                  itemCount: notifikasi.length + 1,
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
                          "Notifikasi akan hilang otomatis dalam 30 hari.",
                          style: GoogleFonts.poppins(
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }

                    final item = notifikasi[index - 1];
                    return NotificationCard(notif: item);
                  },
                ),
              );
            }

            // Default
            return AppWidget().loadingWidget();
          },
        ),
      ),
    );
  }
}
