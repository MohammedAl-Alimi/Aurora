import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:quizwiz/src/features/cards/presentation/presentation.dart';

/// Name of the Hive box that persists lightweight app settings (theme, etc.).
/// Opened in `main._initialize()` before the cubit is created.
const String appSettingsBoxName = 'app_settings';
const String _themeKey = 'themeMode';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_readInitial());

  static ThemeMode _readInitial() {
    try {
      final value = Hive.box<String>(appSettingsBoxName).get(_themeKey);
      switch (value) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
      }
    } catch (_) {/* box not open yet — fall through to default */}
    return ThemeMode.dark;
  }

  void toggleTheme() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _persist(next);
    emit(next);
  }

  void _persist(ThemeMode mode) {
    try {
      Hive.box<String>(appSettingsBoxName)
          .put(_themeKey, mode == ThemeMode.light ? 'light' : 'dark');
    } catch (_) {/* best-effort */}
  }
}
