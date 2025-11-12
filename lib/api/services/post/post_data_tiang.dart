import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class TiangPostService {
  static const String baseUrl = "http://202.169.231.66:82/api/v1/gis/post-data-tiang";

  static Future<bool> postDataTiang({
    required String nomorTiang,
    required String area,
    required String deskripsiTiang,
    File? fotoTiang1,
    File? fotoTiang2,
    File? fotoTiang3,
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
      request.fields['nomor_tiang'] = nomorTiang;
      request.fields['area'] = area;
      request.fields['deskripsi_tiang'] = deskripsiTiang;
      request.fields['latitude'] = latitude;
      request.fields['longitude'] = longitude;
      request.fields['nama_petugas'] = namaPetugas;
      request.fields['status'] = status;
      request.fields['status_notifikasi'] = statusNotifikasi;
      request.fields['tipe_notifikasi'] = tipeNotifikasi;
      request.fields['fcm_token'] = fcmToken;

      // File upload
      if (fotoTiang1 != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto_tiang_1',
          fotoTiang1.path,
        ));
      }

      if (fotoTiang2 != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto_tiang_2',
          fotoTiang2.path,
        ));
      }

      if (fotoTiang3 != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto_tiang_3',
          fotoTiang3.path,
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
