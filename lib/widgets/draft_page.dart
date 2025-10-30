import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraftPage extends StatefulWidget {
  const DraftPage({super.key});

  @override
  State<DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<DraftPage> {
  List<Map<String, dynamic>> drafts = [];

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

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

  Future<void> _deleteDraft(int index) async {
    final prefs = await SharedPreferences.getInstance();
    drafts.removeAt(index);
    await prefs.setString('ont_drafts', jsonEncode(drafts));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.firstBase,
        title: Text("Draft Form ONT",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: drafts.isEmpty
          ? Center(
        child: Text(
          "Belum ada draft tersimpan 💤",
          style: GoogleFonts.poppins(fontSize: 15),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: drafts.length,
        itemBuilder: (context, index) {
          final item = drafts[index];
          final images = item['images'] as List?;

          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === HEADER ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ONT: ${item['ontNumber'] ?? '-'}",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () => _deleteDraft(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Text(
                    "Provinsi: ${item['provinsi'] ?? '-'}",
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  Text(
                    "Petugas: ${item['petugas'] ?? '-'}",
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  Text(
                    "Deskripsi: ${item['deskripsi'] ?? '-'}",
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    "Koordinat: (${item['latitude']?.toStringAsFixed(6) ?? '-'}, "
                        "${item['longitude']?.toStringAsFixed(6) ?? '-'})",
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),

                  // === FOTO ===
                  if (images != null && images.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: images.take(3).map<Widget>((base64Img) {
                        Uint8List bytes = base64Decode(base64Img);
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            bytes,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 10),
                  Text(
                    "Disimpan: ${_formatDate(item['createdAt'])}",
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
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
