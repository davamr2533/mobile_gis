class TiangModel {
  final int id;
  final String nomorTiang;
  final String area;
  final String deskripsiTiang;
  final String fotoTiang1;
  final String fotoTiang2;
  final String fotoTiang3;
  final String latitude;
  final String longitude;
  final String namaPetugas;
  final String status;
  final String createdAt;

  TiangModel({
    required this.id,
    required this.nomorTiang,
    required this.area,
    required this.deskripsiTiang,
    required this.fotoTiang1,
    required this.fotoTiang2,
    required this.fotoTiang3,
    required this.latitude,
    required this.longitude,
    required this.namaPetugas,
    required this.status,
    required this.createdAt,
  });

  factory TiangModel.fromJson(Map<String, dynamic> json) {
    return TiangModel(
      id: json['id'],
      nomorTiang: json['nomor_tiang'],
      area: json['area'],
      deskripsiTiang: json['deskripsi_tiang'],
      fotoTiang1: json['foto_tiang_1'],
      fotoTiang2: json['foto_tiang_2'],
      fotoTiang3: json['foto_tiang_3'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      namaPetugas: json['nama_petugas'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}
