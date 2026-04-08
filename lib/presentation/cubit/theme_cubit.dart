import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _boxName = 'settings_box';
  static const String _themeKey = 'is_dark_mode';

  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = await Hive.openBox(_boxName);
    final isDark = box.get(_themeKey, defaultValue: false);
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    final isDark = state == ThemeMode.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    
    emit(newMode);
    
    final box = await Hive.openBox(_boxName);
    await box.put(_themeKey, !isDark);
  }
}
