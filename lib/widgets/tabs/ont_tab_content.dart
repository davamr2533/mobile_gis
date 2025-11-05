import 'package:flutter/material.dart';
import 'package:gis_mobile/api/models/ont_model.dart';
import 'package:gis_mobile/api/services/get/get_data_ont.dart';
import 'package:gis_mobile/widgets/cards/history_ont_card.dart';
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

  // fungsi untuk refresh data
  Future<void> _refreshData() async {
    setState(() {
      futureOnt = OntService.fetchDataOnt();
    });
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
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                children: [
                  const SizedBox(height: 200),

                  Center(
                    child: Text(
                      'Terjadi kesalahan: ${snapshot.error}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );

          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Data kosong
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                children: [
                  const SizedBox(height: 200),
                  Center(
                    child: Text(
                      'Tidak ada data ONT ditemukan.',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );

          } else {
            //Data berhasil diambil
            final dataOnt = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
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
              )
            );
          }
        }
    );
  }
}