import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moneymate_project/theme/app_theme.dart';
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

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadData();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final db = DatabaseHelper.instance;
    final txMaps = await db.getAllTransactions();
    _transactions = txMaps.map((map) => TransactionModel.fromMap(map)).toList()
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
    setState(() => _isLoading = false);
  }

  double get _balance => _transactions.fold(0.0, (sum, t) => sum + (t.isPemasukan ? t.nominal : -t.nominal));
  double get _totalIncome => _transactions.where((t) => t.isPemasukan).fold(0.0, (sum, t) => sum + t.nominal);
  double get _totalExpense => _transactions.where((t) => !t.isPemasukan).fold(0.0, (sum, t) => sum + t.nominal);

  Future<void> _navigateToAddTransaction() async {
    final result = await Navigator.push<TransactionModel>(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );
    if (result != null) {
      final db = DatabaseHelper.instance;
      await db.insertTransaction(result.toMap());
      await _loadData();
    }
  }

  Future<void> _deleteTransaction(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(child: const Text('Batal'), onPressed: () => Navigator.pop(ctx, false)),
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
      await db.deleteTransaction(id);
      await _loadData();
    }
  }

// Ganti metode build() Anda dengan ini
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Row(children: [
        Image.asset('lib/assets/logo.png', height: 32),
        const SizedBox(width: 12),
        Text('MoneyMate', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ]),
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildBalanceCard(theme),
                const SizedBox(height: 24),
                // Memanggil Card Pie Chart
                _buildIncomeExpenseChart(theme),
                const SizedBox(height: 24),
                // Memanggil Card Transaksi Terbaru
                _buildRecentTransactions(theme),
              ],
            ),
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: _navigateToAddTransaction,
      child: const Icon(Icons.add),
    ),
  );
}


// Ganti metode _buildRecentTransactions() Anda dengan ini
Widget _buildRecentTransactions(ThemeData theme) {
  final incomeList = _transactions.where((t) => t.isPemasukan).toList();
  final expenseList = _transactions.where((t) => !t.isPemasukan).toList();

  // DIUBAH: Membungkus seluruh bagian dengan Card
  return Card(
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0), // Padding atas untuk judul
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Transaksi Terbaru',
              style: theme.textTheme.titleLarge?.copyWith(),
            ),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: 'Pemasukan'),
              Tab(text: 'Pengeluaran'),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(incomeList, 'Belum ada pemasukan.'),
                _buildTransactionList(expenseList, 'Belum ada pengeluaran.'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  // --- WIDGET HELPER ---

  Widget _buildBalanceCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Saldo Saat Ini', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(currencyFormat.format(_balance), style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIncomeExpenseInfo('Pemasukan', _totalIncome, AppColors.income, theme, isIncome: true),
                _buildIncomeExpenseInfo('Pengeluaran', _totalExpense, AppColors.expense, theme, isIncome: false),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseInfo(String title, double amount, Color color, ThemeData theme, {required bool isIncome}) {
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(currencyFormat.format(amount), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: color)),
          ],
        )
      ],
    );
  }

// WIDGET GABUNGAN (DIUBAH UNTUK SPACING & DIVIDER)
// TAMBAHKAN METODE BARU INI
Widget _buildIncomeExpenseChart(ThemeData theme) {
  return Card(
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan',
            style: theme.textTheme.titleLarge?.copyWith(),
          ),
          _buildPieChart(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppColors.income, 'Pemasukan'),
              const SizedBox(width: 24),
              _buildLegendItem(AppColors.expense, 'Pengeluaran'),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildPieChart() {
  if (_totalIncome == 0 && _totalExpense == 0) {
    return const Padding(padding: EdgeInsets.all(40.0), child: Center(child: Text("Belum ada data ringkasan.")));
  }
  final total = _totalIncome + _totalExpense;
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: SizedBox(
      height: 150,
      child: PieChart(
        PieChartData(
          sectionsSpace: 3,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              // Menggunakan warna income baru
              color: AppColors.income, 
              value: _totalIncome,
              title: '${(_totalIncome / total * 100).toStringAsFixed(0)}%',
              radius: 50,
              // DIUBAH: Teks menjadi putih agar kontras dengan ungu
              titleStyle: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              // Menggunakan warna expense baru
              color: AppColors.expense,
              value: _totalExpense,
              title: '${(_totalExpense / total * 100).toStringAsFixed(0)}%',
              radius: 50,
              // DIUBAH: Teks menjadi gelap agar kontras dengan kuning
              titleStyle: const TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildLegendItem(Color color, String text) {
  // Metode ini sudah dinamis dan tidak perlu diubah, karena akan mengambil warna dari AppColors secara otomatis.
  return Row(children: [
    Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 8),
    Text(text),
  ]);
}

  Widget _buildTransactionList(List<TransactionModel> transactions, String emptyMessage) {
    if (transactions.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(32.0), child: Text(emptyMessage, style: const TextStyle(color: Colors.grey))));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionTile(transactions[index]);
      },
    );
  }

Widget _buildTransactionTile(TransactionModel transaction) {
  final theme = Theme.of(context);
  final isIncome = transaction.isPemasukan;
  final color = isIncome ? AppColors.income : AppColors.expense;
  
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    leading: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: 30),
    title: Text(transaction.judul),
    subtitle: Text('${transaction.kategori} • ${DateFormat.yMMMd('id_ID').format(transaction.tanggal)}'),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(currencyFormat.format(transaction.nominal), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        IconButton(
          // DIUBAH: Mengganti warna ikon hapus menjadi ungu
          icon: Icon(Icons.delete, color: theme.colorScheme.primary.withOpacity(0.7)),
          onPressed: () => _deleteTransaction(transaction.id),
        ),
      ],
    ),
  );
}
}
