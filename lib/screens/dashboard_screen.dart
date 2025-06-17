import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

// Format rupiah
final NumberFormat currencyFormat = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

class DashboardScreen extends StatefulWidget {
  final List<Transaction> initialTransactions;

  const DashboardScreen({Key? key, required this.initialTransactions})
    : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late List<Transaction> transactions;

  @override
  void initState() {
    super.initState();
    transactions = List.from(widget.initialTransactions);
  }

  double get balance {
    double sum = 0;
    for (var t in transactions) {
      sum += t.isPemasukan ? t.nominal : -t.nominal;
    }
    return sum;
  }

  void _addNewTransaction(Transaction newTransaction) {
    setState(() {
      transactions.insert(0, newTransaction); // tambah di paling atas
    });
  }

  Future<void> _navigateToAddTransaction() async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(builder: (context) => AddTransactionScreen()),
    );
    if (result != null) {
      _addNewTransaction(result);
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
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return ListTile(
                    leading: Icon(
                      transaction.isPemasukan
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color:
                          transaction.isPemasukan ? Colors.green : Colors.red,
                    ),
                    title: Text(transaction.judul),
                    subtitle: Text(
                      '${transaction.kategori} • ${transaction.tanggal.toLocal().toString().split(' ')[0]}'
                      '${transaction.deskripsi.isNotEmpty ? "\n${transaction.deskripsi}" : ""}',
                    ),
                    trailing: Text(
                      (transaction.isPemasukan ? '+ ' : '- ') +
                          currencyFormat.format(transaction.nominal),
                      style: TextStyle(
                        color:
                            transaction.isPemasukan ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
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
