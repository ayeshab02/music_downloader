// providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

final customColorsProvider = StateNotifierProvider<CustomColorsNotifier, Map<String, Color>>((ref) {
  return CustomColorsNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await prefs.setBool('isDark', state == ThemeMode.dark);
  }
}

class CustomColorsNotifier extends StateNotifier<Map<String, Color>> {
  CustomColorsNotifier() : super({
    'primary': const Color(0xFF9C27B0),
    'secondary': const Color(0xFFE91E63),
  });

  void updateColor(String key, Color color) {
    state = {...state, key: color};
  }
}
