import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OntPostService {
  static const String baseUrl = "http://202.169.231.66:82/api/v1/gis/post-data-ont";

  static Future<bool> postDataOnt({
    required String nomorOnt,
    required String area,
    required String deskripsiRumah,
    required File fotoOnt1,
    required File fotoOnt2,
    required File fotoOnt3,
    required String latitude,
    required String longitude,
    required String namaPetugas,
    required String status,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Field text
      request.fields['nomor_ont'] = nomorOnt;
      request.fields['area'] = area;
      request.fields['deskripsi_rumah'] = deskripsiRumah;
      request.fields['latitude'] = latitude;
      request.fields['longitude'] = longitude;
      request.fields['nama_petugas'] = namaPetugas;
      request.fields['status'] = status;

      // File upload
      request.files.add(await http.MultipartFile.fromPath('foto_ont_1', fotoOnt1.path));
      request.files.add(await http.MultipartFile.fromPath('foto_ont_2', fotoOnt2.path));
      request.files.add(await http.MultipartFile.fromPath('foto_ont_3', fotoOnt3.path));

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
