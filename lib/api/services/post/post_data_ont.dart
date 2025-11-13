import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OntPostService {
  static const String baseUrl = "http://202.169.224.27:8081/api/v1/gis/post-data-ont";

  static Future<bool> postDataOnt({
    required String nomorOnt,
    required String area,
    required String deskripsiRumah,
    File? fotoOnt1,
    File? fotoOnt2,
    File? fotoOnt3,
    required String latitude,
    required String longitude,
    required String namaPetugas,
    required String status,
    required String statusNotifikasi,
    required String tipeNotifikasi,
    required String fcmToken,
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
      request.fields['status_notifikasi'] = statusNotifikasi;
      request.fields['tipe_notifikasi'] = tipeNotifikasi;
      request.fields['fcm_token'] = fcmToken;

      // File upload
      if (fotoOnt1 != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto_ont_1',
          fotoOnt1.path,
        ));
      }

      if (fotoOnt2 != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto_ont_2',
          fotoOnt2.path,
        ));
      }

      if (fotoOnt3 != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto_ont_3',
          fotoOnt3.path,
        ));
      }

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
