import 'package:flutter/material.dart';
import 'package:gis_mobile/api/models/ont_model.dart';
import 'package:gis_mobile/api/services/get/get_data_ont.dart';
import 'package:gis_mobile/widgets/cards/history_ont_card.dart';

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
    return FutureBuilder<List<OntModel>>(
        future: futureOnt,
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
              child: Text('Tidak ada data ONT ditemukan.'),
            );

          } else {
            //Data berhasil diambil
            final dataOnt = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
              itemCount: dataOnt.length,
              itemBuilder: (context, index) {

                final ont = dataOnt[index];

                // Tentukan warna status
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
                    statusColor: statusColor
                );


              }
            );
          }
        }
    );
  }
}