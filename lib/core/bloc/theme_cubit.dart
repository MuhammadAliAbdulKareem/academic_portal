import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_state.dart';

/// Cubit managing dynamic theme mode selection (System, Light, Dark).
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.system));

  /// Explicitly set the theme mode.
  void setThemeMode(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
  }

  /// Toggles between light and dark mode.
  void toggleTheme() {
    if (state.themeMode == ThemeMode.dark) {
      emit(state.copyWith(themeMode: ThemeMode.light));
    } else {
      emit(state.copyWith(themeMode: ThemeMode.dark));
    }
  }
}
