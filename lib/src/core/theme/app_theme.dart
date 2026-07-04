import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// Aurora brand palette — Dusky Petrol, Super Yellow, Lucid Aquamarine.
class AppTheme {
  static const petrol = Color(0xFF254F6B);
  static const superYellow = Color(0xFFE4BA2F);
  static const aquamarine = Color(0xFF2DD4BF);

  static final _lightColors = FlexSchemeColor.from(
    primary: petrol,
    secondary: superYellow,
    tertiary: aquamarine,
    brightness: Brightness.light,
  );

  static final _darkColors = FlexSchemeColor.from(
    primary: const Color(0xFF6FA8CF),
    secondary: superYellow,
    tertiary: aquamarine,
    brightness: Brightness.dark,
  );

  static const _subThemes = FlexSubThemesData(
    blendOnLevel: 8,
    useM2StyleDividerInM3: true,
    defaultRadius: 14,
  );

  static ThemeData lightTheme() => FlexThemeData.light(
        colors: _lightColors,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 6,
        subThemesData: _subThemes,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
      ).copyWith(appBarTheme: const AppBarTheme(centerTitle: true));

  static ThemeData darkTheme() => FlexThemeData.dark(
        colors: _darkColors,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 12,
        subThemesData: _subThemes,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
      ).copyWith(appBarTheme: const AppBarTheme(centerTitle: true));
}
