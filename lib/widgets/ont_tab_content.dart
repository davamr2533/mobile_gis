import 'package:flutter/material.dart';
import 'package:gis_mobile/widgets/history_tab_card.dart';

class OntTabContent extends StatelessWidget {
  const OntTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
      children: [
        HistoryTabCard(
          id: "GIS-TNG-4492",
          location: "Solo",
          status: "Pending",
          statusColor: Colors.orange,
        ),
        HistoryTabCard(
          id: "GIS-TNG-7721",
          location: "Yogyakarta",
          status: "Verified",
          statusColor: Colors.green,
        ),
      ],
    );
  }
}