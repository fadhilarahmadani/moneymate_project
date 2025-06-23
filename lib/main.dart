import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MoneyMateApp());
}

class MoneyMateApp extends StatelessWidget {
  const MoneyMateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyMate',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}