import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../constants/expense_categories.dart';

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
  String? _selectedCategory;
  bool _isPemasukan = false;
  DateTime _tanggal = DateTime.now();

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
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: expenseCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (val) => val == null ? 'Pilih kategori!' : null,
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
                    final newTr = Transaction(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      judul: _judul,
                      nominal: _nominal,
                      tanggal: _tanggal,
                      kategori: _selectedCategory ?? '',
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