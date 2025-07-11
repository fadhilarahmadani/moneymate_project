// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- DIUBAH: Kelas warna disesuaikan dengan palet ungu-kuning ---
class AppColors {
  static const Color primaryAccent = Color(0xFF5C2A9D); // Ungu Tua
  static const Color textDark = Color(0xFF242053);     // Biru Indigo
  static const Color income = Color(0xFFA052C2);        // Ungu Medium
  static const Color expense = Color(0xFFF0B330);       // Kuning Keemasan
}

// Tema utama aplikasi (Light Mode)
final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFFAFAFA),
  primaryColor: AppColors.primaryAccent,
  
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryAccent,
    onPrimary: Colors.white,
    secondary: Color.fromRGBO(240, 179, 48, 1),
    onSecondary: AppColors.textDark,
    surface: Colors.white,
    onSurface: AppColors.textDark,
    error: Color(0xFFD32F2F),
    onError: Colors.white,
  ),
  
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
    bodyColor: AppColors.textDark,
    displayColor: AppColors.textDark,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.textDark,
    elevation: 0,
  ),
  
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primaryAccent,
    unselectedItemColor: Colors.grey,
    elevation: 2,
  ),
  
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryAccent,
    foregroundColor: Colors.white,
  ),
  
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300)
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primaryAccent, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      padding: const EdgeInsets.symmetric(vertical: 16)
    )
  )
);