class TransactionModel {
  final String id;
  final String judul;
  final double nominal;
  final DateTime tanggal;
  final String kategori;
  final String deskripsi;
  final bool isPemasukan;

  TransactionModel({
    required this.id,
    required this.judul,
    required this.nominal,
    required this.tanggal,
    required this.kategori,
    required this.deskripsi,
    required this.isPemasukan,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel(
    id: map['id'],
    judul: map['judul'],
    nominal: map['nominal'],
    tanggal: DateTime.parse(map['tanggal']),
    kategori: map['kategori'],
    deskripsi: map['deskripsi'],
    isPemasukan: map['isPemasukan'] == 1,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'judul': judul,
    'nominal': nominal,
    'tanggal': tanggal.toIso8601String(),
    'kategori': kategori,
    'deskripsi': deskripsi,
    'isPemasukan': isPemasukan ? 1 : 0,
  };
}