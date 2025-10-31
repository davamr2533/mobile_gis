import 'dart:convert';
import 'package:gis_mobile/api/models/tiang_model.dart';
import 'package:http/http.dart' as http;

class TiangService {
  static const String baseUrl = 'http://202.169.231.66:82/api/v1/gis/get-data-tiang';

  static Future<List<TiangModel>> fetchDataTiang() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> tiangList = data['data'];
      return tiangList.map((item) => TiangModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data: ${response.statusCode}');
    }
  }
}