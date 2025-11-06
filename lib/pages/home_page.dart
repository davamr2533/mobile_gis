import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gis_mobile/api/services/get/get_data_ont.dart';
import 'package:gis_mobile/api/services/get/get_data_tiang.dart';
import 'package:gis_mobile/api/services/get/get_provinsi.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:gis_mobile/pages/form_ont_page.dart';
import 'package:gis_mobile/pages/form_tiang_page.dart';
import 'package:gis_mobile/pages/history_page.dart';
import 'package:gis_mobile/widgets/cards/history_home_card.dart';
import 'package:gis_mobile/widgets/pop_up/loading.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  List<String> provinsiList = [];
  List<Map<String, dynamic>> ontHistory = [];
  String? selectedProvinsi;
  bool isOnline = false;
  bool isGpsOn = false;
  bool isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    fetchProvinsi();
    checkConnection();
    checkGpsStatus();
    fetchAllHistory();

    // pantau koneksi secara real-time
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      final hasNetwork = await _hasNetworkConnection(results);
      if (mounted) {
        setState(() {
          isOnline = hasNetwork;
        });
      }
    });

    // === pantau status GPS secara real-time ===
    Geolocator.getServiceStatusStream().listen((ServiceStatus status) async {
      final permission = await Geolocator.checkPermission();
      final gpsActive = status == ServiceStatus.enabled &&
          permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever;

      if (mounted) {
        setState(() {
          isGpsOn = gpsActive;
        });
      }
    });

  }

  // === Ambil daftar provinsi dari API ===
  Future<void> fetchProvinsi() async {
    try {
      final provinsi = await getProvinsi();
      if (mounted) {
        setState(() {
          provinsiList = provinsi;
        });
      }
    } catch (e) {
      debugPrint("Gagal fetch provinsi: $e");
    }
  }

  Future<void> fetchAllHistory() async {
    try {
      final ontData = await OntService.fetchDataOnt();
      final tiangData = await TiangService.fetchDataTiang();


      final combined = [
        ...ontData.map((ont) => {
          'id': ont.id,
          'nomor': ont.nomorOnt,
          'lokasi': ont.area,
          'status': ont.status,
          'jenis': 'ONT', // label asal tabel
          'created_at': ont.createdAt,
        }),
        ...tiangData.map((tiang) => {
          'id': tiang.id,
          'nomor': tiang.nomorTiang,
          'lokasi': tiang.area,
          'status': tiang.status,
          'jenis': 'TIANG',
          'created_at': tiang.createdAt,
        }),
      ];


      combined.sort((a, b) {
        final dateA = DateTime.tryParse((a['created_at'] ?? '').toString()) ?? DateTime(1970);
        final dateB = DateTime.tryParse((b['created_at'] ?? '').toString()) ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });


      if (mounted) {
        setState(() {
          ontHistory = combined.take(3).toList(); // ambil 3 terbaru
          isLoadingHistory = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal ambil data history gabungan: $e");
      if (mounted) {
        setState(() {
          isLoadingHistory = false;
        });
      }
    }
  }



  // === Pastikan benar-benar ada koneksi internet ===
  Future<bool> _hasNetworkConnection(List<ConnectivityResult> results) async {
    if (results.isEmpty || results.first == ConnectivityResult.none) {
      return false;
    }

    try {
      final lookup = await InternetAddress.lookup('google.com');
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // === Cek status koneksi saat halaman pertama kali dibuka ===
  Future<void> checkConnection() async {
    final results = await Connectivity().checkConnectivity();
    final hasNetwork = await _hasNetworkConnection(results);
    if (mounted) {
      setState(() {
        isOnline = hasNetwork;
      });
    }
  }

  // === Cek apakah GPS aktif ===
  Future<void> checkGpsStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Jika GPS belum aktif, tampilkan dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) =>
              AlertDialog(
                title: Text(
                  "Lokasi Tidak Aktif",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Text(
                  "Silakan aktifkan GPS",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await Geolocator.openLocationSettings();
                    },
                    child: Text(
                      "Buka Pengaturan",
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
        );
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (mounted) {
      setState(() {
        isGpsOn = serviceEnabled &&
            permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // background biru bagian atas
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

        // konten utama
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 60),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 80,
            ),
            child: Column(
              children: [
                // === STATUS ONLINE / OFFLINE ===
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Text(
                        isOnline ? "Anda Online!" : "Anda Offline",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.signal_cellular_alt,
                        size: 34,
                        color: isOnline
                            ? AppColors.signalOn
                            : AppColors.signalOff,
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
                                    color: isGpsOn ? AppColors.gpsOn : AppColors.gpsOff,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Center(
                                    child: Text(
                                      isGpsOn ? "GPS Aktif" : "GPS Nonaktif",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isGpsOn ? AppColors.textGreen : AppColors.textRed,
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FormOntPage()),
                          );
                        },
                      ),

                      const SizedBox(width: 25),

                      // === CARD TIANG ===
                      buildMenuCard(
                        icon: Icons.wifi,
                        label: "Form Tiang",
                        color: AppColors.thirdBase,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FormTiangPage()),
                          );
                        },
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

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HistoryPage()),
                          );
                        },
                        child: Text(
                          "See All",
                          style: GoogleFonts.poppins(
                            color: AppColors.secondBase,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      )

                    ],
                  ),
                ),
                const SizedBox(height: 14),

                if (isLoadingHistory)
                  Center(child: AppWidget().loadingWidget())

                else if (!isOnline)
                  Text(
                    "Anda Offline",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  )

                else if (ontHistory.isEmpty)
                  Text(
                    "Belum ada data ONT",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  )
                else
                  Column(
                    children: ontHistory.map((item) {
                      final status = (item['status'] ?? '').toString();
                      final nomor = (item['nomor'] ?? '').toString();
                      final lokasi = (item['lokasi'] ?? '').toString();
                      final jenis = (item['jenis'] ?? '').toString();

                      Color sideColor = Colors.grey;
                      if (status.toLowerCase() == "verified") {
                        sideColor = AppColors.secondBase;
                      } else if (status.toLowerCase() == "pending") {
                        sideColor = AppColors.thirdBase;
                      }

                      return HistoryCard(
                        id: nomor.toString(),
                        location: lokasi.toString(),
                        status: "$jenis - $status",
                        sideColor: sideColor,
                      );
                    }).toList(),
                  )




              ],
            ),
          ),
        ),
      ],
    );
  }

  // === Widget reusable untuk card menu ===
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
        fixedSize: const Size(115, 100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 38),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
