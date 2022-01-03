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
      DynamicPreferencesFlag flag, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(flag.data, value);
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

  Future<bool> removeDynamicPreferencesFlag(DynamicPreferencesFlag flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(flag.data);
  }

  Future<bool> setInt(PreferencesFlag flag, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(flag.toString(), value);
  }

  Future<bool> setDateTime(PreferencesFlag flag, DateTime value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(flag.toString(), value.toIso8601String());
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

  Future<String> getDynamicString(DynamicPreferencesFlag flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(flag.data);
  }

  Future<DateTime> getDateTime(PreferencesFlag flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      return DateTime.parse(prefs.getString(flag.toString()));
    } catch (e) {
      return null;
    }
  }
}
