import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> getProvinsi() async {
  const url = 'https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((prov) => prov['name'].toString()).toList();
  } else {
    throw Exception('Gagal memuat data provinsi');
  }
}
