import 'package:flutter/material.dart';
import 'package:gis_mobile/widgets/tabs/draft_ont.dart';
import 'package:gis_mobile/widgets/tabs/draft_tiang.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gis_mobile/colors/app_colors.dart';

class DraftPage extends StatefulWidget {
  const DraftPage({super.key});

  @override
  State<DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<DraftPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.firstBase,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Draft", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: "ONT"),
            Tab(text: "TIANG"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DraftOntTab(),
          DraftTiangTab(),
        ],
      ),
    );
  }
}
