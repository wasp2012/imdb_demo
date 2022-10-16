import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:imdb_demo/injection.dart';
import 'package:imdb_demo/shared/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/constants/themes.dart';
import 'theme_state.dart';

class ThemeCubitCubit extends Cubit<SettingState> {
  ThemeCubitCubit() : super(SettingState(themeMode: AppTheme.lightTheme));
  bool isDark = false;

  toggleSwitch(bool value) {
    SettingState updatedState;
    if (state.themeMode == AppTheme.lightTheme) {
      saveTheme(isDarkTheme, value);

      updatedState = SettingState(themeMode: AppTheme.darkTheme);
      emit(updatedState);
    } else {
      saveTheme(isDarkTheme, value);

      updatedState = SettingState(themeMode: AppTheme.lightTheme);
      emit(updatedState);
    }
  }

  saveTheme(String key, bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print('saveTheme VAlUE $value');
    preferences.setBool(key, value);
  }

  bool? savedTheme;
  Future<void> getSavedTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    savedTheme = preferences.getBool(isDarkTheme) ?? false;
    print('SavedTheme ??????????????????????${savedTheme}');
  }
}
