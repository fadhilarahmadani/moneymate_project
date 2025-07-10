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

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  List<TransactionModel> transactions = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    final db = DatabaseHelper.instance;
    final List<Map<String, dynamic>> maps = await db.getAllTransactions();
    setState(() {
      transactions = maps.map((map) => TransactionModel.fromMap(map)).toList();
    });
  }

  double get pemasukan => transactions
      .where((t) => t.isPemasukan)
      .fold(0.0, (sum, t) => sum + t.nominal);

  double get pengeluaran => transactions
      .where((t) => !t.isPemasukan)
      .fold(0.0, (sum, t) => sum + t.nominal);

  double get balance => pemasukan - pengeluaran;

  double get pengeluaranPercent {
    final total = pemasukan + pengeluaran;
    if (total == 0) return 0.0;
    return pengeluaran / total;
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

  Widget _buildSummaryCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            const Text(
              'Saldo saat ini',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currencyFormat.format(balance),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                      const SizedBox(height: 4),
                      const Text(
                        'Pemasukan',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currencyFormat.format(pemasukan),
                        style: const TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(height: 40, width: 1, color: Colors.grey[300]),
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.red, size: 20),
                      const SizedBox(height: 4),
                      const Text(
                        'Pengeluaran',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '-${currencyFormat.format(pengeluaran)}',
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Circular progress pengeluaran
            SizedBox(
              height: 130,
              width: 130,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: pengeluaranPercent,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${(pengeluaranPercent * 100).round()}%",
                          style: const TextStyle(
                              fontSize: 26,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Pengeluaran",
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.blue[800],
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.blue[800],
      indicatorWeight: 3,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      tabs: const [
        Tab(text: "Pemasukan"),
        Tab(text: "Pengeluaran"),
      ],
    );
  }

  Widget _buildTransactionList(bool showPemasukan) {
    final filtered = transactions
        .where((t) => t.isPemasukan == showPemasukan)
        .toList()
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

    if (filtered.isEmpty) {
      return const Expanded(
        child: Center(child: Text('Belum ada transaksi')),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final transaction = filtered[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  showPemasukan ? Colors.green[50] : Colors.red[50],
              child: Icon(
                showPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
                color: showPemasukan ? Colors.green : Colors.red,
              ),
            ),
            title: Text(transaction.judul,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              "${transaction.kategori} • ${DateFormat('d MMM yyyy').format(transaction.tanggal)}"
              "${transaction.deskripsi.isNotEmpty ? "\n${transaction.deskripsi}" : ""}",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (showPemasukan ? '' : '-') +
                      currencyFormat.format(transaction.nominal),
                  style: TextStyle(
                    color: showPemasukan ? Colors.green : Colors.red,
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
    );
  }

  Widget _buildTabContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(true),
                _buildTransactionList(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MoneyMate')),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 20),
              _buildTabContent(),
            ],
          ),
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
