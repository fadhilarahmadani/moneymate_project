class Category {
  final String id;
  final String nama;
  final int warna;
  final String ikon;

  Category({required this.id, required this.nama, required this.warna, required this.ikon});

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id'],
    nama: map['nama'],
    warna: map['warna'],
    ikon: map['ikon'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nama': nama,
    'warna': warna,
    'ikon': ikon,
  };
}