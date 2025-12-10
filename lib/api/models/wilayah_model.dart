class WilayahModel {
  final int id;
  final String name;
  final String kode;

  WilayahModel({
    required this.id,
    required this.name,
    required this.kode,
  });

  factory WilayahModel.fromJson(Map<String, dynamic> json) {
    return WilayahModel(
      id: json['id'],
      name: json['name'],
      kode: json['kode'],
    );
  }
}
