// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// CONSTANT
import 'package:notredame/core/constants/preferences_flags.dart';

class PreferencesService {
  Future<bool> setBool(PreferencesFlag flag, {@required bool value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(flag.toString(), value);
  }

  Future<bool> setString(PreferencesFlag flag, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(flag.toString(), value);
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }

  Future<bool> setInt(PreferencesFlag flag, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(flag.toString(), value);
  }

  Future<bool> getBool(PreferencesFlag flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(flag.toString());
  }

  Future<int> getInt(PreferencesFlag flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(flag.toString());
  }

  Future<String> getString(PreferencesFlag flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(flag.toString());
  }
}
