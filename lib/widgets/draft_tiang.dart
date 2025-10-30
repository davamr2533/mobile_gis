import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gis_mobile/widgets/pop_up.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DraftTiangTab extends StatefulWidget {
  const DraftTiangTab({super.key});

  @override
  State<DraftTiangTab> createState() => _DraftTiangTabState();
}

class _DraftTiangTabState extends State<DraftTiangTab> {
  List<Map<String, dynamic>> drafts = [];

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('tiang_drafts');
    if (raw != null) {
      final List list = jsonDecode(raw);
      setState(() {
        drafts = List<Map<String, dynamic>>.from(list);
      });
    }
  }

  Future<void> _deleteDraft(int index) async {
    final prefs = await SharedPreferences.getInstance();

    // Hapus draft dari list lokal
    setState(() {
      drafts.removeAt(index);
    });

    // Simpan ulang list draft yang sudah dihapus ke SharedPreferences
    final encoded = jsonEncode(drafts);
    await prefs.setString('tiang_drafts', encoded);

  }

  @override
  Widget build(BuildContext context) {
    if (drafts.isEmpty) {
      return Center(
        child: Text(
          "Belum ada draft Tiang tersimpan",
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
                                "GIS-ID-${item['tiangNumber'] ?? '-'}",
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
                        onPressed: () => _showDetailDialog(context, item, images, pageController),
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
                                  builder: (context) => PopUpDeleteSuccess()
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

  void _showDetailDialog(BuildContext context, Map<String, dynamic> item, List? images, PageController pageController) {
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
                  _buildDetail("Nomor Tiang", "GIS-ID-${item['tiangNumber'] ?? '-'}"),
                  _buildDetail("Provinsi", item['provinsi']),
                  _buildDetail("Petugas", item['petugas']),
                  _buildDetail("Deskripsi", item['deskripsi']),
                  const Divider(),
                  const SizedBox(height: 8),
                  _coordRow("Latitude", "${item['latitude']?.toStringAsFixed(6) ?? '-'}"),
                  _coordRow("Longitude", "${item['longitude']?.toStringAsFixed(6) ?? '-'}"),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.thirdBase,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: Text("Kembali",
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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

  String _formatDate(String? isoDate) {
    if (isoDate == null) return "-";
    final date = DateTime.tryParse(isoDate);
    if (date == null) return "-";
    return "${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}";
  }
}
