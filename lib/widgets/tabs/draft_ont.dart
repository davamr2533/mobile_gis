import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gis_mobile/widgets/pop_up/loading.dart';
import 'package:gis_mobile/widgets/pop_up/pop_up_delete_confirm.dart';
import 'package:gis_mobile/widgets/pop_up/pop_up_delete_success.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:gis_mobile/widgets/pop_up/pop_up_failed.dart';
import 'package:gis_mobile/widgets/pop_up/pop_up_success.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;

class DraftOntTab extends StatefulWidget {
  const DraftOntTab({super.key});

  @override
  State<DraftOntTab> createState() => _DraftOntTabState();
}

class _DraftOntTabState extends State<DraftOntTab> {
  List<Map<String, dynamic>> drafts = [];

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  //fungsi untuk ambil data draft dari shared preferences
  Future<void> _loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ont_drafts');
    if (raw != null) {
      final List list = jsonDecode(raw);
      setState(() {
        drafts = List<Map<String, dynamic>>.from(list);
      });
    }
  }

  //fungsi untuk hapus data di draft
  Future<void> _deleteDraft(int index) async {
    final prefs = await SharedPreferences.getInstance();

    // Hapus draft dari list lokal
    setState(() {
      drafts.removeAt(index);
    });

    // Simpan ulang list draft yang sudah dihapus ke SharedPreferences
    final encoded = jsonEncode(drafts);
    await prefs.setString('ont_drafts', encoded);
  }

  //Fungsi untuk upload data dari draft ke server
  Future<void> _uploadToServer(Map<String, dynamic> item, List? images, int index) async {
    try {
      if (images == null || images.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gambar tidak tersedia")),
        );
        return;
      }

      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: AppWidget().loadingWidget()),
      );

      // ✅ Ambil FCM token
      String? token = await FirebaseMessaging.instance.getToken();

      // Kirim ke API
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("http://202.169.224.27:8081/api/v1/gis/post-data-ont"),
      );

      // Field
      request.fields.addAll({
        "nomor_ont": item['ontNumber'],
        "area": item['provinsi'],
        "deskripsi_rumah": item['deskripsi'],
        "latitude": item['latitude'].toString(),
        "longitude": item['longitude'].toString(),
        "nama_petugas": item['petugas'],
        "status": "Pending",
        "status_notifikasi": "Pending",
        "tipe_notifikasi": "Submitted",
        "fcm_token": token ?? "",
      });

      // Kirim file langsung dari base64 (tanpa kompres)
      for (int i = 0; i < images.length; i++) {
        Uint8List bytes = base64Decode(images[i]);
        final tempDir = Directory.systemTemp;
        final file = await File('${tempDir.path}/upload_${DateTime.now().millisecondsSinceEpoch}_$i.jpg')
            .writeAsBytes(bytes);
        request.files.add(await http.MultipartFile.fromPath('foto_ont_${i + 1}', file.path));
      }

      // Kirim request
      final response = await request.send();

      Navigator.pop(context); // tutup loading

      if (response.statusCode == 200) {
        await _deleteDraft(index);
        Navigator.pop(context);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const PopUpSuccess(),
        );

        // Tutup otomatis setelah 2 detik
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.pop(context);
          }
        });

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal upload: ${response.statusCode}")),
        );

      }

    } catch (e) {

      Navigator.pop(context);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const PopUpFailed(),
      );

      // Tutup otomatis setelah 2 detik
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (drafts.isEmpty) {
      return Center(
        child: Text(
          "Belum ada draft ONT tersimpan",
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: drafts.length,
      itemBuilder: (context, index) {
        final item = drafts[index];
        final images = item['images'] as List?;
        final pageController = PageController();

        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              children: [
                if (images != null && images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.memory(
                          base64Decode(images.first),
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          width: double.infinity,
                          height: 150,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                "GIS-ID-${item['ontNumber'] ?? '-'}",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 80),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                item['provinsi'],
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.fifthBase,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showDetailDialog(context, item, images, pageController, index),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.thirdBase,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                        ),
                        child: Text(
                          "Cek Detail",
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    //Hapus data dari draft
                    GestureDetector(
                      onTap: () => {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => PopUpDelete(
                            onConfirm: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const PopUpDeleteSuccess(),
                              );
                              await _deleteDraft(index);
                            },
                          ),
                        ),
                      },

                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.fifthBase,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Center(
                          child: Icon(Icons.delete_forever_rounded, color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetailDialog(BuildContext context, Map<String, dynamic> item, List? images, PageController pageController, int index) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (images != null && images.isNotEmpty)
                    Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: pageController,
                            itemCount: images.length,
                            itemBuilder: (context, i) {
                              Uint8List bytes = base64Decode(images[i]);
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(bytes, width: double.infinity, fit: BoxFit.cover),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        SmoothPageIndicator(
                          controller: pageController,
                          count: images.length,
                          effect: ExpandingDotsEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            spacing: 6,
                            activeDotColor: AppColors.thirdBase,
                            dotColor: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      _formatDate(item['createdAt']),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetail("Nomor ONT", "GIS-ID-${item['ontNumber'] ?? '-'}"),
                  _buildDetail("Provinsi", item['provinsi']),
                  _buildDetail("Petugas", item['petugas']),
                  _buildDetail("Deskripsi", item['deskripsi']),
                  const Divider(),

                  if (item['latitude'] != null && item['longitude'] != null)
                    _mapPreview(
                      item['latitude'],
                      item['longitude'],
                    ),

                  const SizedBox(height: 8),
                  _coordRow("Latitude", "${item['latitude']?.toStringAsFixed(6) ?? '-'}"),
                  _coordRow("Longitude", "${item['longitude']?.toStringAsFixed(6) ?? '-'}"),
                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _uploadToServer(item, images, index),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: Text(
                        "Kirim Ulang",
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.thirdBase,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: Text(
                        "Kembali",
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetail(String label, String? value) {
    return Container(
      width: double.infinity,
      height: 45,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppColors.fifthBase, borderRadius: BorderRadius.circular(12)),
      child: Text(
        "$value",
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDarkGray),
      ),
    );
  }

  Widget _coordRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 8),
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.textSoftGray),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                "$value",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapPreview(double lat, double lng) {
    return Container(
      height: 150,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.hardEdge,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(lat, lng),
          initialZoom: 15,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.drag |
            InteractiveFlag.pinchZoom |
            InteractiveFlag.doubleTapZoom |
            InteractiveFlag.flingAnimation,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.gis_mobile',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(lat, lng),
                width: 50,
                height: 50,
                child: const Icon(Icons.location_pin,
                    color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }


  String _formatDate(String? isoDate) {
    if (isoDate == null) return "-";
    final date = DateTime.tryParse(isoDate);
    if (date == null) return "-";
    return "${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}";
  }
}
