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

  Future<bool> setDynamicString(
      PreferencesFlag flag, String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString('${flag.toString()}_$key', value);
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }

  Future<Object> getPreferencesFlag(PreferencesFlag flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(flag.toString());
  }

  Future<bool> removePreferencesFlag(PreferencesFlag flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(flag.toString());
  }

  Future<bool> removeDynamicPreferencesFlag(
      PreferencesFlag flag, String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove('${flag.toString()}_$key');
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

  Future<String> getDynamicString(PreferencesFlag flag, String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('${flag.toString()}_$key');
  }
}
