import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class TiangPostService {
  static const String baseUrl = "http://202.169.231.66:82/api/v1/gis/post-data-tiang";

  static Future<bool> postDataTiang({
    required String nomorTiang,
    required String area,
    required String deskripsiTiang,
    required File fotoTiang1,
    required File fotoTiang2,
    required File fotoTiang3,
    required String latitude,
    required String longitude,
    required String namaPetugas,
    required String status,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Field text
      request.fields['nomor_tiang'] = nomorTiang;
      request.fields['area'] = area;
      request.fields['deskripsi_tiang'] = deskripsiTiang;
      request.fields['latitude'] = latitude;
      request.fields['longitude'] = longitude;
      request.fields['nama_petugas'] = namaPetugas;
      request.fields['status'] = status;

      // File upload
      request.files.add(await http.MultipartFile.fromPath('foto_tiang_1', fotoTiang1.path));
      request.files.add(await http.MultipartFile.fromPath('foto_tiang_2', fotoTiang2.path));
      request.files.add(await http.MultipartFile.fromPath('foto_tiang_3', fotoTiang3.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var data = jsonDecode(respStr);
        print("✅ Response: $data");

        return data['status'] == 'success';
      } else {
        print("❌ Gagal kirim, code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error: $e");
      return false;
    }
  }
}
