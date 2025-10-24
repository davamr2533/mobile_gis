import 'package:flutter/material.dart';
import 'package:gis_mobile/api/get_provinsi.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:gis_mobile/form/form_ont.dart';
import 'package:gis_mobile/form/form_tiang.dart';
import 'package:gis_mobile/widgets/history_card.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  List<String> provinsiList = [];
  String? selectedProvinsi;

  @override
  void initState() {
    super.initState();
    fetchProvinsi(); // ambil data saat halaman pertama kali dibuka
  }

  // === Ambil daftar provinsi dari API ===
  Future<void> fetchProvinsi() async {
    final provinsi = await getProvinsi();
    setState(() {
      provinsiList = provinsi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 220,
          decoration: const BoxDecoration(
            color: AppColors.firstBase,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 60),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 80,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Text(
                        "Anda Offline!",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.signal_cellular_alt,
                        size: 34,
                        color: AppColors.signalOff,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // === CARD INFO UTAMA ===
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "GIS Mobile",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "Explore, locate, synchronize",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textSoftGray,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.gpsOff,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Center(
                                    child: Text(
                                      "GPS Offline",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textRed,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Image.asset(
                            'assets/profil.png',
                            width: 80,
                            height: 80,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // === CARD ONT & TIANG ===
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // === CARD ONT ===
                      buildMenuCard(
                          icon: Icons.router,
                          label: "Form ONT",
                          color: AppColors.secondBase,
                          onPressed: () => showFormOnt(context)
                      ),

                      const SizedBox(width: 25),

                      // === CARD TIANG ===
                      buildMenuCard(
                          icon: Icons.wifi,
                          label: "Form Tiang",
                          color: AppColors.thirdBase,
                          onPressed: () => showFormTiang(context)
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // === HISTORY ===
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        "History",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "See All",
                        style: GoogleFonts.poppins(
                          color: AppColors.secondBase,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const HistoryCard(
                  id: "GIS-ONT-1224",
                  location: "Yogyakarta",
                  status: "Pending",
                ),
                const HistoryCard(
                  id: "GIS-ONT-1234",
                  location: "Surakarta",
                  status: "Pending",
                ),
                const HistoryCard(
                  id: "GIS-ONT-2255",
                  location: "Jakarta",
                  status: "Verified",
                  sideColor: AppColors.secondBase,
                ),
              ],
            ),

          ),



        ),
      ],
    );
  }

  static Widget buildMenuCard({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return FilledButton(
      onPressed: onPressed ?? () {},
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        fixedSize: const Size(135, 120),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 48),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }


}
