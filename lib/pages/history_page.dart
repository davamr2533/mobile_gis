import 'package:flutter/material.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:gis_mobile/pages/draft_page.dart';
import 'package:gis_mobile/widgets/tabs/ont_tab_content.dart';
import 'package:gis_mobile/widgets/tabs/tiang_tab_content.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,

        //App bar------------------------------------------
        appBar: AppBar(
          backgroundColor: AppColors.firstBase,
          title: Text(
            "History",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600
            ),
          ),

          //Tombol untuk akses draft
          actions: [
            IconButton(
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DraftPage()),
                );

              },
              icon: const Icon(
                Icons.edit_note_outlined,
                color: Colors.white,
                size: 36,
              ),
            ),
          ],

          //Tab Bar ----------------------------------------
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Container(
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: TabBar(

                  //Indicator Tab Bar
                  indicator: BoxDecoration(
                    color: AppColors.thirdBase,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  indicatorPadding: EdgeInsets.all(4),

                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.firstBase,

                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16
                  ),

                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),

                  tabs: [
                    Tab(
                      text: 'ONT',
                    ),
                    Tab(
                      text: 'Tiang',
                    ),
                  ]
              ),
            ),
          ),
        ),

        //Body---------------------------------------------
        body: TabBarView(children: [
          OntTabContent(),
          TiangTabContent()
        ]),
      ),
    );
  }
}
