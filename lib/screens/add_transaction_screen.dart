import 'package:flutter/material.dart';
import 'package:moneymate_project/models/transaction.dart';
import 'package:moneymate_project/models/category.dart';
import 'package:moneymate_project/db/database_helper.dart';
import 'package:moneymate_project/screens/master_data_screen.dart';
import 'package:intl/intl.dart';

// Helper untuk konversi nama ikon (string) ke IconData
IconData iconFromString(String iconName) {
  // ... (Fungsi ini tidak perlu diubah)
  switch (iconName) {
    case 'fastfood':
      return Icons.fastfood;
    case 'shopping_cart':
      return Icons.shopping_cart;
    case 'home':
      return Icons.home;
    case 'directions_bus':
      return Icons.directions_bus;
    case 'school':
      return Icons.school;
    case 'local_hospital':
      return Icons.local_hospital;
    case 'movie':
      return Icons.movie;
    default:
      return Icons.category;
  }
}

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // --- Bagian State dan Logika tidak ada perubahan signifikan ---
  final _formKey = GlobalKey<FormState>();
  String _judul = '';
  String _deskripsi = '';
  double _nominal = 0;
  Category? _selectedCategory;
  bool _isPemasukan = false;
  DateTime _tanggal = DateTime.now();

  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _loadCategories();
  }

  Future<List<Category>> _loadCategories() async {
    final db = DatabaseHelper.instance;
    final List<Map<String, dynamic>> maps = await db.getAllCategories();
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<void> _navigateToMasterData() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MasterDataScreen()),
    );
    // Setelah kembali, refresh dropdown kategori
    setState(() {
      _categoriesFuture = _loadCategories();
      _selectedCategory = null;
    });
  }

  // --- Perubahan utama ada di dalam method build() di bawah ini ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        // DIUBAH: Membuat app bar transparan sesuai tema
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Judul'),
                onSaved: (val) => _judul = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Judul wajib diisi!' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nominal',
                  prefixText: 'Rp ', // DIUBAH: Tambahan prefix
                ),
                keyboardType: TextInputType.number,
                onSaved: (val) => _nominal = double.tryParse(val ?? '0') ?? 0,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Nominal wajib diisi!';
                  }
                  if (double.tryParse(val) == null) {
                    return 'Nominal tidak valid!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FutureBuilder<List<Category>>(
                      future: _categoriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text(
                              'Belum ada kategori. Tambahkan dulu.');
                        }
                        final categories = snapshot.data!;
                        return DropdownButtonFormField<Category>(
                          value: categories.any((c) => c.id == _selectedCategory?.id)
                              ? _selectedCategory
                              : null,
                          decoration:
                              const InputDecoration(labelText: 'Kategori'),
                          items: categories
                              .map((c) => DropdownMenuItem<Category>(
                                    value: c,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Color(c.warna),
                                          radius: 10,
                                          child: Icon(iconFromString(c.ikon),
                                              size: 14, color: Colors.white),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(c.nama),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val),
                          validator: (val) =>
                              val == null ? 'Pilih kategori!' : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // DIUBAH: Tombol settings yang mengikuti tema
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                    icon: Icon(Icons.settings, color: colorScheme.primary),
                    tooltip: "Kelola Kategori",
                    onPressed: _navigateToMasterData,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Deskripsi (opsional)'),
                onSaved: (val) => _deskripsi = val ?? '',
              ),
              const SizedBox(height: 8),
              // DIUBAH: Switch yang mengikuti tema
              SwitchListTile(
                title: const Text('Pemasukan?'),
                value: _isPemasukan,
                onChanged: (val) => setState(() => _isPemasukan = val),
                activeColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
              ),
              const SizedBox(height: 8),
              // DIUBAH: ListTile Tanggal yang mengikuti tema
              ListTile(
                title: const Text('Tanggal'),
                subtitle: Text(DateFormat.yMMMMd('id_ID').format(_tanggal)),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today, color: colorScheme.primary),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _tanggal,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _tanggal = picked);
                  },
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(12)
                ),
              ),
              const SizedBox(height: 24),
              // DIUBAH: Tombol Simpan yang mengikuti tema
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    )
                  ),
                  child: const Text('Simpan Transaksi'),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      final newTr = TransactionModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        judul: _judul,
                        nominal: _nominal,
                        tanggal: _tanggal,
                        kategori: _selectedCategory!.nama,
                        deskripsi: _deskripsi,
                        isPemasukan: _isPemasukan,
                      );
                      Navigator.pop(context, newTr);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}