class NotifikasiModel {
  final int id;
  final String nomor;
  final String jenis;
  final String tipeNotifikasi;
  final String status;
  final String createdAt;

  NotifikasiModel({
    required this.id,
    required this.nomor,
    required this.jenis,
    required this.tipeNotifikasi,
    required this.status,
    required this.createdAt,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: json['id'],
      nomor: json['nomor'],
      jenis: json['jenis'],
      tipeNotifikasi: json['tipe_notifikasi'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}
