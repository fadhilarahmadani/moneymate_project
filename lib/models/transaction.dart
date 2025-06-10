class Transaction {
  final String id;
  final String judul;
  final double nominal;
  final DateTime tanggal;
  final String kategori;
  final String deskripsi;
  final bool isPemasukan;

  Transaction({
    required this.id,
    required this.judul,
    required this.nominal,
    required this.tanggal,
    required this.kategori,
    required this.deskripsi,
    required this.isPemasukan,
  });
}