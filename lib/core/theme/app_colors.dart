import 'package:flutter/material.dart';

/// Palet warna resmi Smart Space Booking sesuai PRD Bagian III §2.1.
class AppColors {
  AppColors._();

  // Ink (Teks & Elemen Gelap)
  static const Color ink900 = Color(0xFF1C1917); // Teks utama
  static const Color ink600 = Color(0xFF57534E); // Teks sekunder, label
  static const Color ink300 = Color(0xFFA8A29E); // Placeholder, teks nonaktif

  // Surface & Border
  static const Color surface0 = Color(0xFFFFFFFF); // Latar kartu
  static const Color surface50 = Color(0xFFFAF9F7); // Latar layar warm off-white
  static const Color border = Color(0xFFE7E3DE); // Garis pembatas, divider

  // Brand Colors
  static const Color primary = Color(0xFFC2540E); // Ember - Terakota Hangat
  static const Color primaryContainer = Color(0xFFFBE7D8); // Latar chip/badge primer
  static const Color secondary = Color(0xFF0E5C56); // Deep Teal
  static const Color secondaryContainer = Color(0xFFDCEEEC); // Latar info non-status

  // Status Colors
  static const Color success = Color(0xFF2F7A4D); // Status Selesai, konfirmasi berhasil
  static const Color warning = Color(0xFFB8860B); // Status Belum Dikonfirmasi
  static const Color info = Color(0xFF1D6FA5); // Status Aktif/Digunakan
  static const Color danger = Color(0xFFB3261E); // Status Dibatalkan, error
}
