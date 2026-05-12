import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Scheme ────────────────────────────────────────────────────────
  
  // Light theme colors
  static const Color _lightPrimary = Color(0xFF3B82F6); // Blue
  static const Color _lightPrimaryVariant = Color(0xFF2563EB);
  static const Color _lightSecondary = Color(0xFF10B981); // Green
  static const Color _lightSecondaryVariant = Color(0xFF059669);
  static const Color _lightSurface = Color(0xFFFFFFFF); // White
  static const Color _lightBackground = Color(0xFFF0F9FF); // Light blue - complementary to dark theme
  static const Color _lightError = Color(0xFFEF4444);
  
  // Dark theme colors
  static const Color _darkPrimary = Color(0xFF60A5FA); // Lighter Blue
  static const Color _darkPrimaryVariant = Color(0xFF3B82F6);
  static const Color _darkSecondary = Color(0xFF34D399); // Lighter Green
  static const Color _darkSecondaryVariant = Color(0xFF10B981);
  static const Color _darkSurface = Color(0xFF1F2937);
  static const Color _darkBackground = Color(0xFF0F1B2D); // Complementary to light theme
  static const Color _darkError = Color(0xFFF87171);
  
  // Category colors (consistent across themes)
  static const Map<String, Color> categoryColors = {
    'food': Color(0xFFF87171),
    'transport': Color(0xFF3B82F6),
    'entertainment': Color(0xFFA78BFA),
    'health': Color(0xFFFBBF24),
    'shopping': Color(0xFFF472B6),
    'utilities': Color(0xFF34D399),
    'education': Color(0xFF60A5FA),
    'other': Color(0xFF94A3B8),
  };
  
  // ── Light Theme ────────────────────────────────────────────────────────
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        primaryContainer: _lightPrimaryVariant,
        secondary: _lightSecondary,
        secondaryContainer: _lightSecondaryVariant,
        surface: _lightSurface,
        background: _lightBackground,
        error: _lightError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1F2937),
        onBackground: Color(0xFF1F2937),
        onError: Colors.white,
      ),
      
      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: Color(0xFF1F2937),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _lightError),
        ),
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
  
  // ── Dark Theme ─────────────────────────────────────────────────────────
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        primaryContainer: _darkPrimaryVariant,
        secondary: _darkSecondary,
        secondaryContainer: _darkSecondaryVariant,
        surface: _darkSurface,
        background: _darkBackground,
        error: _darkError,
        onPrimary: Color(0xFF1F2937),
        onSecondary: Color(0xFF1F2937),
        onSurface: Color(0xFFF9FAFB),
        onBackground: Color(0xFFF9FAFB),
        onError: Color(0xFF1F2937),
      ),
      
      // Text themes for dark mode
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        displayMedium: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        displaySmall: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        headlineMedium: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        headlineSmall: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        titleLarge: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        titleMedium: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        titleSmall: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        bodyLarge: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins',
        ),
        bodyMedium: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins',
        ),
        bodySmall: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins',
        ),
        labelLarge: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
        labelMedium: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
        labelSmall: const TextStyle(
          color: Color(0xFFE8F4FF),
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
      
      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: Color(0xFFF9FAFB),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFFF9FAFB),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: const Color(0xFF1F2937),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _darkError),
        ),
        labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkPrimary,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 4,
      ),
    );
  }
  
  // ── Helper Methods ─────────────────────────────────────────────────────
  
  static Color getCategoryColor(String category) {
    return categoryColors[category.toLowerCase()] ?? categoryColors['other']!;
  }
  
  static Color getCategoryColorForTheme(String category, bool isDark) {
    final baseColor = getCategoryColor(category);
    // Adjust color brightness based on theme if needed
    return baseColor;
  }
}
