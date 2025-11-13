import 'dart:convert';
import 'package:gis_mobile/api/models/ont_model.dart';
import 'package:http/http.dart' as http;

class OntService {
  static const String baseUrl = 'http://202.169.224.27:8081/api/v1/gis/get-data-ont';

  static Future<List<OntModel>> fetchDataOnt() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> ontList = data['data'];
      return ontList.map((item) => OntModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data: ${response.statusCode}');
    }
  }
}
