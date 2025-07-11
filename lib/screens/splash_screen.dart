import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // DIUBAH: Ambil data tema saat ini
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // DIUBAH: Gunakan warna latar dari tema
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pastikan Anda memiliki logo yang cocok untuk light & dark mode
            // atau gunakan Icon sebagai alternatif.
            Image.asset('lib/assets/logo.png', height: 100),
            const SizedBox(height: 24),
            Text(
              "MoneyMate",
              style: theme.textTheme.displaySmall?.copyWith(
                // DIUBAH: Gunakan warna primer dari tema
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}