import 'package:flutter/material.dart';
import 'models/transaction.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MoneyMateApp());
}

class MoneyMateApp extends StatelessWidget {
  const MoneyMateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data untuk transaksi awal
    final List<Transaction> dummyTransactions = [
      Transaction(
        id: 't1',
        judul: 'Gaji Bulanan',
        nominal: 5000000,
        tanggal: DateTime.now().subtract(const Duration(days: 2)),
        kategori: 'Pemasukan',
        deskripsi: 'Gaji bulan Juni',
        isPemasukan: true,
      ),
      Transaction(
        id: 't2',
        judul: 'Makan Siang',
        nominal: 25000,
        tanggal: DateTime.now().subtract(const Duration(days: 1)),
        kategori: 'Makanan & Minuman',
        deskripsi: '',
        isPemasukan: false,
      ),
    ];

    return MaterialApp(
      title: 'MoneyMate',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: DashboardScreen(initialTransactions: dummyTransactions),
      debugShowCheckedModeBanner: false,
    );
  }
}