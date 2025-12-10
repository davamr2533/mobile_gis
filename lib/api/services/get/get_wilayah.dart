import 'dart:convert';
import 'package:gis_mobile/api/models/wilayah_model.dart';
import 'package:http/http.dart' as http;

class WilayahService {
  static const String baseUrl = 'http://202.169.224.27:8081/api/v1/gis/get-wilayah';

  static Future<List<WilayahModel>> fetchDataWilayah() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> wilayahList = data['data'];
      return wilayahList.map((item) => WilayahModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data: ${response.statusCode}');
    }
  }
}