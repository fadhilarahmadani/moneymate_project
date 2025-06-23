import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
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

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final db = DatabaseHelper.instance;
    final txMaps = await db.getAllTransactions();
    final catMaps = await db.getAllCategories();
    setState(() {
      _allTransactions = txMaps.map((m) => TransactionModel.fromMap(m)).toList();
      _allCategories = catMaps.map((m) => Category.fromMap(m)).toList();
      _applyFilter();
    });
  }

  void _applyFilter() {
    List<TransactionModel> list = List.from(_allTransactions);

    // Filter by category
    if (_selectedCategory != null) {
      list = list.where((tr) => tr.kategori == _selectedCategory!.nama).toList();
    }

    // Filter by week
    if (_selectedWeek != null) {
      list = list.where((tr) {
        final tgl = tr.tanggal;
        return !tgl.isBefore(_selectedWeek!.start) && !tgl.isAfter(_selectedWeek!.end);
      }).toList();
    }

    setState(() {
      _filteredTransactions = list;
    });
  }

  Future<void> _pickWeek() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateInWeek ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
      helpText: 'Pilih tanggal dalam minggu yang ingin difilter',
    );
    if (picked != null) {
      // Hitung awal dan akhir minggu (Senin-Minggu)
      final monday = picked.subtract(Duration(days: picked.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      setState(() {
        _selectedWeek = DateTimeRange(start: monday, end: sunday);
        _selectedDateInWeek = picked;
      });
      _applyFilter();
    }
  }

  Widget buildPieChart(List<TransactionModel> filteredTransactions, List<Category> allCategories) {
    // Hitung total nominal per kategori
    final Map<String, double> categoryTotals = {};
    for (var cat in allCategories) {
      categoryTotals[cat.nama] = 0;
    }
    for (var tr in filteredTransactions) {
      categoryTotals[tr.kategori] = (categoryTotals[tr.kategori] ?? 0) + tr.nominal * (tr.isPemasukan ? 1 : -1);
    }

    // Hanya tampilkan kategori dengan nominal != 0
    final entries = categoryTotals.entries.where((e) => e.value.abs() > 0).toList();

    if (entries.isEmpty) {
      return const Center(child: Text('Tidak ada data untuk pie chart'));
    }

    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.brown, Colors.cyan, Colors.amber, Colors.pink,
    ];

    final total = entries.fold<double>(0, (sum, e) => sum + e.value.abs());

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: List.generate(entries.length, (i) {
            final entry = entries[i];
            return PieChartSectionData(
              color: colors[i % colors.length],
              value: entry.value.abs(),
              title: '${entry.key}\n${(entry.value.abs() / total * 100).toStringAsFixed(1)}%',
              radius: 60,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }),
          sectionsSpace: 2,
          centerSpaceRadius: 32,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String weekLabel = 'Semua waktu';
    if (_selectedWeek != null) {
      weekLabel =
          'Minggu: ${DateFormat('dd MMM yyyy').format(_selectedWeek!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedWeek!.end)}';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Filter Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Filter Kategori'),
              items: [
                const DropdownMenuItem<Category>(
                  value: null,
                  child: Text('Semua Kategori'),
                ),
                ..._allCategories.map((cat) => DropdownMenuItem<Category>(
                      value: cat,
                      child: Text(cat.nama),
                    ))
              ],
              onChanged: (val) {
                setState(() => _selectedCategory = val);
                _applyFilter();
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text(weekLabel)),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Pilih Minggu'),
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
            const SizedBox(height: 16),
            buildPieChart(_filteredTransactions, _allCategories),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? const Center(child: Text('Tidak ada transaksi ditemukan'))
                  : ListView.builder(
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final tr = _filteredTransactions[index];
                        return ListTile(
                          leading: Icon(
                            tr.isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
                            color: tr.isPemasukan ? Colors.green : Colors.red,
                          ),
                          title: Text(tr.judul),
                          subtitle: Text(
                            '${tr.kategori} • ${DateFormat('yyyy-MM-dd').format(tr.tanggal)}'
                            '${tr.deskripsi.isNotEmpty ? "\n${tr.deskripsi}" : ""}',
                          ),
                          trailing: Text(
                            (tr.isPemasukan ? '+ ' : '- ') + currencyFormat.format(tr.nominal),
                            style: TextStyle(
                              color: tr.isPemasukan ? Colors.green : Colors.red,
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
    );
  }
}