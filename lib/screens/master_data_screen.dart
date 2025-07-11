import 'package:flutter/material.dart';
import 'package:moneymate_project/theme/app_theme.dart'; // DIUBAH: Tambahkan import ini
import '../db/database_helper.dart';
import '../models/category.dart';

final List<Category> defaultCategories = [
  Category(id: '1', nama: 'Makanan', warna: 0xFFF0B330, ikon: 'fastfood'),
  Category(id: '2', nama: 'Transportasi', warna: 0xFF5C2A9D, ikon: 'directions_bus'),
  Category(id: '3', nama: 'Belanja', warna: 0xFFA052C2, ikon: 'shopping_cart'),
  Category(id: '4', nama: 'Kesehatan', warna: 0xFF242053, ikon: 'local_hospital'),
  Category(id: '5', nama: 'Hiburan', warna: 0xFF5C2A9D, ikon: 'movie'),
];

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
    case 'category':
      return Icons.category;
    default:
      return Icons.category;
  }
}

class MasterDataScreen extends StatefulWidget {
  const MasterDataScreen({Key? key}) : super(key: key);

  @override
  State<MasterDataScreen> createState() => _MasterDataScreenState();
}

class _MasterDataScreenState extends State<MasterDataScreen> {
  Future<List<Category>>? _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _insertDefaultCategoriesIfNeeded().then((_) => _loadCategories());
  }

  Future<void> _refreshCategories() async {
    setState(() {
      _categoriesFuture = _loadCategories();
    });
  }

  Future<void> _insertDefaultCategoriesIfNeeded() async {
    final db = DatabaseHelper.instance;
    final existing = await db.getAllCategories();
    if (existing.isEmpty) {
      for (final cat in defaultCategories) {
        await db.insertCategory(cat.toMap());
      }
    }
  }

  Future<List<Category>> _loadCategories() async {
    final db = DatabaseHelper.instance;
    final maps = await db.getAllCategories();
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  void _addCategory() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Kategori'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nama kategori',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text('Tambah'),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx, text);
              }
            },
          ),
        ],
      ),
    );
    if (result != null) {
      final db = DatabaseHelper.instance;
      final newCategory = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: result,
        warna: 0xFF90A4AE,
        ikon: 'category',
      );
      await db.insertCategory(newCategory.toMap());
      _refreshCategories();
    }
  }

  // DIUBAH: Pindahkan metode _deleteCategory ke dalam sini
  void _deleteCategory(Category cat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus kategori "${cat.nama}"?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            child: const Text('Hapus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final db = DatabaseHelper.instance;
      await db.deleteCategory(cat.id);
      _refreshCategories();
    }
  }

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  return Scaffold(
    appBar: AppBar(
      title: const Text('Master Kategori'),
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
    ),
    body: FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada kategori'));
        }
        final categories = snapshot.data!;
        return ListView.builder(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary, // Latar Ungu
                  child: Icon(
                    iconFromString(cat.ikon),
                    color: AppColors.expense, // Ikon Kuning
                    size: 22,
                  ),
                ),
                title: Text(cat.nama, style: theme.textTheme.titleMedium),
                trailing: IconButton(
                  // DIUBAH: Mengganti warna ikon hapus menjadi ungu
                  icon: Icon(Icons.delete, color: theme.colorScheme.primary.withOpacity(0.7)),
                  onPressed: () => _deleteCategory(cat),
                ),
              ),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _addCategory,
      tooltip: 'Tambah Kategori',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.add),
    ),
  );
}
}
