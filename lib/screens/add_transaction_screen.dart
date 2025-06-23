import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../db/database_helper.dart';
import 'master_data_screen.dart';

// Helper untuk konversi nama ikon (string) ke IconData
IconData iconFromString(String iconName) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Judul'),
                onSaved: (val) => _judul = val ?? '',
                validator: (val) => val == null || val.isEmpty ? 'Judul wajib diisi!' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nominal'),
                keyboardType: TextInputType.number,
                onSaved: (val) => _nominal = double.tryParse(val ?? '0') ?? 0,
                validator: (val) => val == null || double.tryParse(val) == null ? 'Nominal tidak valid!' : null,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: FutureBuilder<List<Category>>(
                      future: _categoriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Belum ada kategori. Tambahkan kategori dulu.');
                        }
                        final categories = snapshot.data!;
                        return DropdownButtonFormField<Category>(
                          value: categories.any((c) => c.id == _selectedCategory?.id)
                              ? _selectedCategory
                              : null,
                          decoration: const InputDecoration(labelText: 'Kategori'),
                          items: categories
                              .map((c) => DropdownMenuItem<Category>(
                                    value: c,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Color(c.warna),
                                          radius: 10,
                                          child: Icon(iconFromString(c.ikon), size: 14, color: Colors.white),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(c.nama),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedCategory = val),
                          validator: (val) => val == null ? 'Pilih kategori!' : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.green),
                    tooltip: "Kelola Kategori",
                    onPressed: _navigateToMasterData,
                  ),
                ],
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
                onSaved: (val) => _deskripsi = val ?? '',
              ),
              SwitchListTile(
                title: const Text('Pemasukan?'),
                value: _isPemasukan,
                onChanged: (val) => setState(() => _isPemasukan = val),
              ),
              ListTile(
                title: const Text('Tanggal'),
                subtitle: Text('${_tanggal.toLocal()}'.split(' ')[0]),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
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
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Simpan'),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final newTr = TransactionModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      judul: _judul,
                      nominal: _nominal,
                      tanggal: _tanggal,
                      kategori: _selectedCategory!.nama, // bisa pakai .id untuk foreign key
                      deskripsi: _deskripsi,
                      isPemasukan: _isPemasukan,
                    );
                    Navigator.pop(context, newTr);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}