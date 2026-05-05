import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateProvider<ThemeMode>((ref) {
  // Tema por defecto: Oscuro
  return ThemeMode.dark;
});
