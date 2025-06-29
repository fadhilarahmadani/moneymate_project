import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../db/database_helper.dart';
import 'add_transaction_screen.dart';

final NumberFormat currencyFormat = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final db = DatabaseHelper.instance;
    final List<Map<String, dynamic>> maps = await db.getAllTransactions();
    setState(() {
      transactions = maps.map((map) => TransactionModel.fromMap(map)).toList();
    });
  }

  double get balance {
    double sum = 0;
    for (var t in transactions) {
      sum += t.isPemasukan ? t.nominal : -t.nominal;
    }
    return sum;
  }

  Future<void> _addNewTransaction(TransactionModel newTransaction) async {
    final db = DatabaseHelper.instance;
    await db.insertTransaction(newTransaction.toMap());
    await _loadTransactions();
  }

  Future<void> _deleteTransaction(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            child: const Text('Hapus'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final db = DatabaseHelper.instance;
      await db.deleteTransaction(id);
      await _loadTransactions();
    }
  }

  Future<void> _navigateToAddTransaction() async {
    final result = await Navigator.push<TransactionModel>(
      context,
      MaterialPageRoute(builder: (context) => AddTransactionScreen()),
    );
    if (result != null) {
      await _addNewTransaction(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MoneyMate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo saat ini',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      currencyFormat.format(balance),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Transaksi Terbaru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text('Belum ada transaksi'))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return ListTile(
                          leading: Icon(
                            transaction.isPemasukan
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: transaction.isPemasukan
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text(transaction.judul),
                          subtitle: Text(
                            '${transaction.kategori} • ${transaction.tanggal.toLocal().toString().split(' ')[0]}'
                            '${transaction.deskripsi.isNotEmpty ? "\n${transaction.deskripsi}" : ""}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                (transaction.isPemasukan ? '+ ' : '- ') +
                                    currencyFormat.format(transaction.nominal),
                                style: TextStyle(
                                  color: transaction.isPemasukan
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTransaction(transaction.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransaction,
        child: const Icon(Icons.add),
        tooltip: 'Tambah Transaksi',
      ),
    );
  }
}