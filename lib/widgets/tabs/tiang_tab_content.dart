import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gis_mobile/api/cubit/tiang_cubit.dart';
import 'package:gis_mobile/api/models/tiang_model.dart';
import 'package:gis_mobile/api/services/get/get_data_tiang.dart';
import 'package:gis_mobile/widgets/cards/history_tiang_card.dart';
import 'package:gis_mobile/widgets/pop_up/loading.dart';
import 'package:google_fonts/google_fonts.dart';

class TiangTabContent extends StatefulWidget {
  const TiangTabContent({super.key});

  @override
  State<TiangTabContent> createState() => _TiangTabContent();
}

class _TiangTabContent extends State<TiangTabContent> {
  late Future<List<TiangModel>> futureTiang;

  @override
  void initState() {
    super.initState();
    futureTiang = TiangService.fetchDataTiang();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TiangCubit()..fetchTiangData(),
      child: BlocBuilder<TiangCubit, TiangState>(
          builder: (context, state) {

            //State Loading
            if (state is TiangLoading) {
              return AppWidget().loadingWidget();
            }

            //State Error
            if (state is TiangError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            //State Data Kosong
            if (state is TiangEmpty) {
              return Center(
                child: Text(
                  'Tidak ada data Tiang ditemukan.',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              );
            }

            //State Data berhasil diambil
            if (state is TiangLoaded) {
              final dataTiang = state.data;

              return RefreshIndicator(
                onRefresh: () async => context.read<TiangCubit>().fetchTiangData(),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                  itemCount: dataTiang.length,
                  itemBuilder: (context, index) {
                    final tiang = dataTiang[index];

                    Color statusColor;
                    switch (tiang.status.toLowerCase()) {
                      case 'pending':
                        statusColor = Colors.orange;
                        break;
                      case 'verified':
                        statusColor = Colors.green;
                        break;
                      default:
                        statusColor = Colors.grey;
                    }

                    return HistoryTiangCard(
                      tiang: tiang,
                      statusColor: statusColor,
                    );
                  },
                ),
              );
            }

            // Default (initial state)
            return AppWidget().loadingWidget();
          }
      ),
    );
  }
}