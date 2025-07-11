import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moneymate_project/theme/app_theme.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../db/database_helper.dart';

final NumberFormat currencyFormat = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

class SearchTransactionScreen extends StatefulWidget {
  const SearchTransactionScreen({Key? key}) : super(key: key);

  @override
  State<SearchTransactionScreen> createState() => _SearchTransactionScreenState();
}

class _SearchTransactionScreenState extends State<SearchTransactionScreen> {
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  List<Category> _allCategories = [];
  Category? _selectedCategory;
  DateTime? _selectedDateInWeek;
  DateTimeRange? _selectedWeek;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final db = DatabaseHelper.instance;
    final txMaps = await db.getAllTransactions();
    final catMaps = await db.getAllCategories();
    setState(() {
      _allTransactions = txMaps.map((m) => TransactionModel.fromMap(m)).toList();
      _allCategories = catMaps.map((m) => Category.fromMap(m)).toList();
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    List<TransactionModel> list = List.from(_allTransactions);
    if (_selectedCategory != null) {
      list = list.where((tr) => tr.kategori == _selectedCategory!.nama).toList();
    }
    if (_selectedWeek != null) {
      list = list.where((tr) {
        final tgl = tr.tanggal;
        return !tgl.isBefore(_selectedWeek!.start) && !tgl.isAfter(_selectedWeek!.end);
      }).toList();
    }
    setState(() => _filteredTransactions = list);
  }

  Future<void> _pickWeek() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateInWeek ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      final monday = picked.subtract(Duration(days: picked.weekday - 1));
      final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59));
      setState(() {
        _selectedWeek = DateTimeRange(start: monday, end: sunday);
        _selectedDateInWeek = picked;
      });
      _applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Transaksi'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView( // DIUBAH: Kembali menggunakan ListView agar bisa scroll 3 card
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildFilterCard(),
                const SizedBox(height: 24),
                // DIUBAH: Memanggil Card untuk Chart dan List secara terpisah
                _buildChartCard(),
                const SizedBox(height: 24),
                _buildTransactionListCard(),
              ],
            ),
    );
  }

  // --- WIDGET HELPER BARU ---

  Widget _buildFilterCard() {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<Category>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Filter Kategori',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<Category>(
                  value: null, child: Text('Semua Kategori')),
              ..._allCategories.map((cat) =>
                  DropdownMenuItem<Category>(value: cat, child: Text(cat.nama)))
            ],
            onChanged: (val) {
              setState(() => _selectedCategory = val);
              _applyFilter();
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // DIUBAH: Teks hanya muncul jika _selectedWeek tidak null
              Expanded(
                child: _selectedWeek == null
                    ? const SizedBox.shrink() // Tidak menampilkan apa-apa
                    : Text(
                        '${DateFormat.yMMMd('id_ID').format(_selectedWeek!.start)} - ${DateFormat.yMMMd('id_ID').format(_selectedWeek!.end)}',
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                // DIUBAH: Teks tombol berubah jika sudah ada tanggal
                label: Text(_selectedWeek == null ? 'Pilih Minggu' : 'Ganti'),
                onPressed: _pickWeek,
              ),
              if (_selectedWeek != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Reset Minggu',
                  onPressed: () {
                    setState(() {
                      _selectedWeek = null;
                      _selectedDateInWeek = null;
                    });
                    _applyFilter();
                  },
                )
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildChartCard() {
  Map<String, double> categoryTotals = {};
  for (var tr in _filteredTransactions) {
    categoryTotals[tr.kategori] = (categoryTotals[tr.kategori] ?? 0) + tr.nominal;
  }
  
  final chartData = categoryTotals.entries.where((e) => e.value > 0).toList();

  if (chartData.isEmpty) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(48.0),
        child: Center(child: Text("Tidak ada data untuk ditampilkan pada grafik.")),
      ),
    );
  }

  final double totalValue = chartData.fold(0.0, (sum, item) => sum + item.value);

  // DIUBAH: Menambahkan lebih banyak variasi warna yang kontras
  final List<Color> chartColors = [
    AppColors.primaryAccent,   // Ungu Tua
    AppColors.expense,         // Kuning Keemasan
    AppColors.income,          // Ungu Medium
    const Color(0xFF48A9A6),   // Teal (Biru Kehijauan)
    AppColors.textDark,        // Biru Indigo
    const Color(0xFFC38DDB),   // Ungu Muda
    const Color(0xFFFFD668),   // Kuning Muda
  ];

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: List.generate(chartData.length, (i) {
                  final entry = chartData[i];
                  final percentage = (entry.value / totalValue * 100);

                  return PieChartSectionData(
                    color: chartColors[i % chartColors.length], 
                    value: entry.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: 60,
                    titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 2)]),
                  );
                }),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16.0,
            runSpacing: 10.0,
            alignment: WrapAlignment.center,
            children: List.generate(chartData.length, (i) {
              final entry = chartData[i];
              return _buildLegendItem(chartColors[i % chartColors.length], entry.key);
            }),
          )
        ],
      ),
    ),
  );
}

// Ganti juga metode ini
Widget _buildLegendItem(Color color, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4)
        ),
      ),
      const SizedBox(width: 6),
      Text(text),
    ],
  );
}

  Widget _buildTransactionListCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hasil Transaksi', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 24),
            if (_filteredTransactions.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text("Tidak ada transaksi ditemukan.")))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredTransactions.length,
                itemBuilder: (context, index) {
                  final tr = _filteredTransactions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      tr.isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
                      color: tr.isPemasukan ? AppColors.income : AppColors.expense,
                    ),
                    title: Text(tr.judul),
                    subtitle: Text('${tr.kategori} • ${DateFormat.yMMMd('id_ID').format(tr.tanggal)}'),
                    trailing: Text(
                      currencyFormat.format(tr.nominal),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: tr.isPemasukan ? AppColors.income : AppColors.expense,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}