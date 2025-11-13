import 'package:flutter/material.dart';
import 'package:gis_mobile/api/models/ont_model.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:gis_mobile/widgets/cards/detail_ont_card.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryOntCard extends StatelessWidget {
  final OntModel ont;
  final Color statusColor;

  const HistoryOntCard({
    super.key,
    required this.ont,
    required this.statusColor

  });

  @override
  Widget build(BuildContext context) {

    //Card Utama
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8,
          right: 8,
          top: 8,
          bottom: 2
        ),
        child: Column(
          children: [
            
            Stack(
              children: [

                ClipRRect(
                    borderRadius: BorderRadiusGeometry.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.4),
                        BlendMode.darken,
                      ),
                      child: Image.network(
                        _fixUrl(ont.fotoOnt1 ?? ''),
                        width: double.infinity,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.fifthBase,
                          height: 100,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image,
                              color: Colors.grey, size: 40),
                        ),
                      ),
                    )
                ),

                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ont.createdAt.split(' ')[0],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Colors.white
                        ),
                      ),

                      SizedBox(height: 45),

                      Text(
                        "GIS-ID-${ont.nomorOnt}",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Colors.white
                        ),
                      ),
                    ],
                  ),
                )



              ],
            ),
            


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.thirdBase,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)
                        ),
                        shadowColor: WidgetStateColor.transparent
                    ),
                    onPressed: () {

                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => DetailOntCard(ont: ont),
                      );

                    },
                    child: Text(
                      "Cek Detail",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 8),


                Text(
                  ont.status,
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),


          ],
        )
      ),
    );
  }

  String _fixUrl(String url) {
    if (url.isEmpty) return '';

    if (url.startsWith('http://localhost')) {
      return url.replaceAll('http://localhost', 'http://202.169.224.27:8081');
    } else if (!url.startsWith('http')) {
      return 'http://202.169.224.27:8081$url';
    }
    return url;
  }

}