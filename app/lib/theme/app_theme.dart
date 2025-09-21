import 'package:flutter/material.dart';

class AppTheme {
  // Color definitions based on design system
  static const Color primaryColor = Color(0xFF030213);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color mutedColor = Color(0xFFECECF0);
  static const Color accentColor = Color(0xFFE9EBEF);
  static const Color destructiveColor = Color(0xFFD4183D);
  
  // Secondary color mapped from oklch(0.95 0.0058 264.53) to neutral light tone
  // This is approximately a very light gray with slight blue tint
  static const Color secondaryColor = Color(0xFFF2F2F5);
  
  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkMutedColor = Color(0xFF2A2A2A);
  static const Color darkAccentColor = Color(0xFF3A3A3A);
  static const Color darkSecondaryColor = Color(0xFF2A2A2A);

  // Border radius constant
  static const double borderRadius = 10.0;

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
        background: backgroundColor,
        error: destructiveColor,
        onPrimary: Colors.white,
        onSecondary: primaryColor,
        onSurface: primaryColor,
        onBackground: primaryColor,
        onError: Colors.white,
        outline: mutedColor,
        outlineVariant: accentColor,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: backgroundColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: accentColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: destructiveColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: mutedColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accentColor,
        selectedColor: primaryColor,
        labelStyle: const TextStyle(
          color: primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: mutedColor,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: darkSecondaryColor,
        surface: darkSurfaceColor,
        background: darkBackgroundColor,
        error: destructiveColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
        outline: darkMutedColor,
        outlineVariant: darkAccentColor,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurfaceColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkAccentColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: destructiveColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: darkMutedColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkAccentColor,
        selectedColor: primaryColor,
        labelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkMutedColor,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Text theme builder
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light 
        ? primaryColor 
        : Colors.white;
    
    return TextTheme(
      // Headlines
      headlineLarge: TextStyle(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      headlineSmall: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      // Titles
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      titleMedium: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      // Body text
      bodyLarge: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      // Labels
      labelLarge: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      labelMedium: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      labelSmall: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
    );
  }

  // Helper method to get border radius
  static BorderRadius get borderRadiusAll => BorderRadius.circular(borderRadius);
  
  // Helper method to get primary color
  static Color get primary => primaryColor;
  
  // Helper method to get background color
  static Color get background => backgroundColor;
  
  // Helper method to get muted color
  static Color get muted => mutedColor;
  
  // Helper method to get accent color
  static Color get accent => accentColor;
  
  // Helper method to get destructive color
  static Color get destructive => destructiveColor;
  
  // Helper method to get secondary color
  static Color get secondary => secondaryColor;
}
