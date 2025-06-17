import 'package:flutter/material.dart';
import '../constants/expense_categories.dart';

class MasterDataScreen extends StatefulWidget {
  const MasterDataScreen({Key? key}) : super(key: key);

  @override
  State<MasterDataScreen> createState() => _MasterDataScreenState();
}

class _MasterDataScreenState extends State<MasterDataScreen> {
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
            hintText: 'Nama kategori pengeluaran',
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
              if (text.isNotEmpty && !expenseCategories.contains(text)) {
                Navigator.pop(ctx, text);
              }
            },
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() {
        expenseCategories.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Kategori',
            onPressed: _addCategory,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: expenseCategories.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.label_outline),
            title: Text(expenseCategories[index]),
          );
        },
      ),
    );
  }
}