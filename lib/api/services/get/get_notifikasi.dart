import 'dart:convert';
import 'package:gis_mobile/api/models/notifikasi_model.dart';
import 'package:http/http.dart' as http;

class NotifikasiService {
  static const String baseUrl = 'http://202.169.224.27:8081/api/v1/gis/get-notifikasi';

  static Future<List<NotifikasiModel>> fetchDataNotifikasi() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> notifikasiList = data['data'];
      return notifikasiList.map((item) => NotifikasiModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data: ${response.statusCode}');
    }
  }
}