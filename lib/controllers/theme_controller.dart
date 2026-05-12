import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/app_theme.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  
  final GetStorage _storage = GetStorage();
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  
  // ── Getters ───────────────────────────────────────────────────────────────
  
  ThemeMode get themeMode => _themeMode.value;
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;
  bool get isLightMode => _themeMode.value == ThemeMode.light;
  bool get isSystemMode => _themeMode.value == ThemeMode.system;
  
  // ── Initialization ───────────────────────────────────────────────────────
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }
  
  // ── Theme Management ───────────────────────────────────────────────────────
  
  void _loadThemeFromStorage() {
    final savedTheme = _storage.read('theme_mode');
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'dark':
          _themeMode.value = ThemeMode.dark;
          break;
        case 'light':
          _themeMode.value = ThemeMode.light;
          break;
        case 'system':
          _themeMode.value = ThemeMode.system;
          break;
      }
    }
  }
  
  void _saveThemeToStorage() {
    String themeString;
    switch (_themeMode.value) {
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    _storage.write('theme_mode', themeString);
  }
  
  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    _saveThemeToStorage();
    Get.changeThemeMode(mode);
  }
  
  void toggleTheme() {
    switch (_themeMode.value) {
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
        break;
    }
  }
  
  void setLightMode() => setThemeMode(ThemeMode.light);
  void setDarkMode() => setThemeMode(ThemeMode.dark);
  void setSystemMode() => setThemeMode(ThemeMode.system);
  
  // ── Theme Helpers ─────────────────────────────────────────────────────────
  
  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;
  
  Color getCategoryColor(String category) {
    return AppTheme.getCategoryColor(category);
  }
  
  Color getCategoryColorForTheme(String category, bool isDark) {
    return AppTheme.getCategoryColorForTheme(category, isDark);
  }
  
  // ── Reactive Updates ─────────────────────────────────────────────────────
  
  @override
  void onReady() {
    super.onReady();
    // Apply initial theme
    Get.changeThemeMode(_themeMode.value);
  }
}
