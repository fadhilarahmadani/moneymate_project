import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  double _nominal = 0;
  String _kategori = expenseCategories[0];
  String _deskripsi = '';
  bool _isPemasukan = false;
  DateTime _tanggal = DateTime.now();

  // Untuk format rupiah preview
  String _formattedNominal = '';
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final transaksiBaru = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        judul: _judul,
        nominal: _nominal,
        tanggal: _tanggal,
        kategori: _kategori,
        deskripsi: _deskripsi,
        isPemasukan: _isPemasukan,
      );
      Navigator.of(context).pop(transaksiBaru);
    }
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
                validator: (value) => value == null || value.isEmpty ? 'Judul wajib diisi' : null,
                onSaved: (value) => _judul = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nominal'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || double.tryParse(value.replaceAll('.', '').replaceAll(',', '')) == null ? 'Nominal tidak valid' : null,
                onChanged: (value) {
                  setState(() {
                    final n = double.tryParse(value.replaceAll('.', '').replaceAll(',', '')) ?? 0;
                    _formattedNominal = currencyFormat.format(n);
                  });
                },
                onSaved: (value) => _nominal = double.tryParse(value!.replaceAll('.', '').replaceAll(',', '')) ?? 0,
              ),
              if (_formattedNominal.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8),
                  child: Text('Format: $_formattedNominal', style: TextStyle(color: Colors.grey[700])),
                ),
              DropdownButtonFormField<String>(
                value: _kategori,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: expenseCategories
                    .map((kategori) => DropdownMenuItem(
                          value: kategori,
                          child: Text(kategori),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _kategori = value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
                onSaved: (value) => _deskripsi = value ?? '',
              ),
              SwitchListTile(
                title: const Text('Pemasukan'),
                value: _isPemasukan,
                onChanged: (value) => setState(() => _isPemasukan = value),
              ),
              ListTile(
                title: Text('Tanggal: ${_tanggal.toLocal().toString().split(' ')[0]}'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _tanggal,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _tanggal = picked);
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}