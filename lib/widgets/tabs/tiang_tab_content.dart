import 'package:flutter/material.dart';
import 'package:gis_mobile/api/models/tiang_model.dart';
import 'package:gis_mobile/api/services/get_data_tiang.dart';
import 'package:gis_mobile/widgets/cards/history_tiang_card.dart';

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
    return FutureBuilder<List<TiangModel>>(
        future: futureTiang,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading
            return const Center(child: CircularProgressIndicator());

          } else if (snapshot.hasError) {
            // Error
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );

          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Data kosong
            return const Center(
              child: Text('Tidak ada data Tiang ditemukan.'),
            );

          } else {
            //Data berhasil diambil
            final dataTiang = snapshot.data!;

            return ListView.builder(
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                itemCount: dataTiang.length,
                itemBuilder: (context, index) {

                  final tiang = dataTiang[index];

                  // Tentukan warna status
                  Color statusColor;
                  switch (tiang.status.toLowerCase()) {
                    case 'progress':
                      statusColor = Colors.orange;
                      break;
                    case 'verified':
                      statusColor = Colors.green;
                      break;
                    case 'pending':
                      statusColor = Colors.yellow;
                      break;
                    default:
                      statusColor = Colors.grey;
                  }

                  return HistoryTiangCard(
                      tiang: tiang,
                      statusColor: statusColor
                  );


                }
            );
          }
        }
    );
  }
}