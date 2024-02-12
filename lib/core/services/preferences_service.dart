// Flutter imports:

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/core/constants/preferences_flags.dart';

// CONSTANT

class PreferencesService {
  final persistentsKey = [
    PreferencesFlag.discoveryDashboard,
    PreferencesFlag.discoveryETS,
    PreferencesFlag.discoveryGradeDetails,
    PreferencesFlag.discoveryMore,
    PreferencesFlag.discoverySchedule,
    PreferencesFlag.discoveryStudentGrade,
    PreferencesFlag.discoveryStudentProfile,
    PreferencesFlag.ratingTimer,
    PreferencesFlag.hasRatingBeenRequested
  ];

  Future<bool> setBool(PreferencesFlag flag, {required bool value}) async {
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

  /// Get persitent flags and reput them in the cache once the clear is done
  Future<void> clearWithoutPersistentKey() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<PreferencesFlag, dynamic> allPersistentPrefs = {};

    // Save the persistent flags
    for (final flag in persistentsKey) {
      final value = prefs.get(flag.toString());

      if (value != null) {
        allPersistentPrefs[flag] = value;
      }
    }

    // Clear the cache
    prefs.clear();

    // Put the persistent flags back in the preferences
    allPersistentPrefs.forEach((key, value) async {
      if (value is bool) {
        await setBool(key, value: value);
      } else if (value is String) {
        await setString(key, value);
      }
    });
  }

  Future<Object?> getPreferencesFlag(PreferencesFlag flag) async {
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

  Future<bool> setDateTime(PreferencesFlag flag, DateTime value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(flag.toString(), value.toIso8601String());
  }

  Future<bool?> getBool(PreferencesFlag flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(flag.toString());
  }

  Future<int?> getInt(PreferencesFlag flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(flag.toString());
  }

  Future<String?> getString(PreferencesFlag flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(flag.toString());
  }

  Future<String?> getDynamicString(PreferencesFlag flag, String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('${flag.toString()}_$key');
  }

  Future<DateTime?> getDateTime(PreferencesFlag flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final flagPreference = prefs.getString(flag.toString());

    if (flagPreference != null) {
      return DateTime.parse(flagPreference);
    }

    return null;
  }
}
