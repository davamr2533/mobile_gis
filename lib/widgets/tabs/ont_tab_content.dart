import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gis_mobile/api/cubit/ont_cubit.dart';
import 'package:gis_mobile/api/models/ont_model.dart';
import 'package:gis_mobile/api/services/get/get_data_ont.dart';
import 'package:gis_mobile/widgets/cards/history_ont_card.dart';
import 'package:gis_mobile/widgets/pop_up/loading.dart';
import 'package:google_fonts/google_fonts.dart';

class OntTabContent extends StatefulWidget {
  const OntTabContent({super.key});

  @override
  State<OntTabContent> createState() => _OntTabContent();
}

class _OntTabContent extends State<OntTabContent> {
  late Future<List<OntModel>> futureOnt;

  @override
  void initState() {
    super.initState();
    futureOnt = OntService.fetchDataOnt();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OntCubit()..fetchOntData(),
      child: BlocBuilder<OntCubit, OntState>(
          builder: (context, state) {

            //State Loading
            if (state is OntLoading) {
              return AppWidget().loadingWidget();
            }

            //State Error
            if (state is OntError) {
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
            if (state is OntEmpty) {
              return Center(
                child: Text(
                  'Tidak ada data ONT ditemukan.',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              );
            }

            //State Data berhasil diambil
            if (state is OntLoaded) {
              final dataOnt = state.data;

              //Urutkan dari yang terbaru (createdAt paling besar)
              dataOnt.sort((a, b) {
                final dateA = DateTime.tryParse(a.createdAt) ?? DateTime(0);
                final dateB = DateTime.tryParse(b.createdAt) ?? DateTime(0);
                return dateB.compareTo(dateA);
              });

              return RefreshIndicator(
                onRefresh: () async => context.read<OntCubit>().fetchOntData(),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                  itemCount: dataOnt.length,
                  itemBuilder: (context, index) {
                    final ont = dataOnt[index];

                    Color statusColor;
                    switch (ont.status.toLowerCase()) {
                      case 'pending':
                        statusColor = Colors.orange;
                        break;
                      case 'verified':
                        statusColor = Colors.green;
                        break;
                      default:
                        statusColor = Colors.grey;
                    }

                    return HistoryOntCard(
                      ont: ont,
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