import 'package:flutter/material.dart';

class AppTheme {
  // Color definitions based on 색상명세서.md
  // 메인 색상 (Primary): #4FC3F7 - 밝고 경쾌한 하늘색
  static const Color primaryColor = Color(0xFF4FC3F7);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color mutedColor = Color(0xFFECECF0);
  static const Color accentColor = Color(0xFFE9EBEF);
  static const Color destructiveColor = Color(0xFFD4183D);
  
  // 서브 색상 (Sub) - 투명도 변형들
  static const Color sub100 = Color(0xFF4FC3F7); // rgba(79, 195, 247, 1.0) - CTA 버튼, 메인 강조
  static const Color sub80 = Color(0xCC4FC3F7);  // rgba(79, 195, 247, 0.8) - 카드 배경, Hover 효과
  static const Color sub60 = Color(0x994FC3F7);  // rgba(79, 195, 247, 0.6) - 보조 아이콘, 서브 텍스트 강조
  static const Color sub40 = Color(0x664FC3F7);  // rgba(79, 195, 247, 0.4) - 구분선, 그래프 영역
  static const Color sub20 = Color(0x334FC3F7);  // rgba(79, 195, 247, 0.2) - 하이라이트 배경, 섀도우 블러
  static const Color sub10 = Color(0x1A4FC3F7);  // rgba(79, 195, 247, 0.1) - 선택 영역, 약한 강조 오버레이
  
  // Secondary color - 서브 색상의 연한 버전
  static const Color secondaryColor = Color(0x1A4FC3F7); // sub10과 동일
  
  // Dark theme colors - 다크 모드에서도 메인 색상 유지하되 배경은 어둡게
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkMutedColor = Color(0xFF2A2A2A);
  static const Color darkAccentColor = Color(0xFF3A3A3A);
  static const Color darkSecondaryColor = Color(0x1A4FC3F7); // 다크 모드에서도 서브 색상 사용

  // Border radius constant
  static const double borderRadius = 10.0;

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: sub100,
        secondary: secondaryColor,
        surface: backgroundColor,
        background: backgroundColor,
        error: destructiveColor,
        onPrimary: Colors.white,
        onSecondary: sub100,
        onSurface: sub100,
        onBackground: sub100,
        onError: Colors.white,
        outline: mutedColor,
        outlineVariant: accentColor,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: sub100,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: sub100,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: backgroundColor,
        elevation: 2,
        shadowColor: sub20, // 서브 색상의 섀도우 사용
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sub100, // 메인 강조 색상 사용
          foregroundColor: Colors.white,
          shadowColor: sub20, // 서브 색상의 섀도우
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
          foregroundColor: sub100,
          side: const BorderSide(color: sub100),
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
          foregroundColor: sub100,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sub10, // 서브 색상의 연한 버전 사용
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
          borderSide: const BorderSide(color: sub100, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: destructiveColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: sub100,
        unselectedItemColor: mutedColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accentColor,
        selectedColor: sub100,
        labelStyle: const TextStyle(
          color: sub100,
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
        primary: sub100,
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
        shadowColor: sub20, // 다크 모드에서도 서브 색상의 섀도우 사용
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sub100, // 다크 모드에서도 메인 색상 사용
          foregroundColor: Colors.white,
          shadowColor: sub20,
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
          borderSide: const BorderSide(color: sub100, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: destructiveColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: sub100,
        unselectedItemColor: darkMutedColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkAccentColor,
        selectedColor: sub100,
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
        ? sub100 
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
  static Color get primary => sub100;
  
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
  
  // Helper methods for sub colors
  static Color get sub100Color => sub100;
  static Color get sub80Color => sub80;
  static Color get sub60Color => sub60;
  static Color get sub40Color => sub40;
  static Color get sub20Color => sub20;
  static Color get sub10Color => sub10;
}