class OntModel {
  final int id;
  final String nomorOnt;
  final String area;
  final String deskripsiRumah;
  final String? fotoOnt1;
  final String? fotoOnt2;
  final String? fotoOnt3;
  final String latitude;
  final String longitude;
  final String namaPetugas;
  final String status;
  final String statusNotifikasi;
  final String tipeNotifikasi;
  final String fcmToken;
  final String createdAt;

  OntModel({
    required this.id,
    required this.nomorOnt,
    required this.area,
    required this.deskripsiRumah,
    this.fotoOnt1,
    this.fotoOnt2,
    this.fotoOnt3,
    required this.latitude,
    required this.longitude,
    required this.namaPetugas,
    required this.status,
    required this.statusNotifikasi,
    required this.tipeNotifikasi,
    required this.fcmToken,
    required this.createdAt,
  });

  factory OntModel.fromJson(Map<String, dynamic> json) {
    return OntModel(
      id: json['id'],
      nomorOnt: json['nomor_ont'],
      area: json['area'],
      deskripsiRumah: json['deskripsi_rumah'],
      fotoOnt1: json['foto_ont_1'],
      fotoOnt2: json['foto_ont_2'],
      fotoOnt3: json['foto_ont_3'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      namaPetugas: json['nama_petugas'],
      status: json['status'],
      statusNotifikasi: json['status_notifikasi'],
      tipeNotifikasi: json['tipe_notifikasi'],
      fcmToken: json['fcm_token'],
      createdAt: json['created_at'],
    );
  }
}
