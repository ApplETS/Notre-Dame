// Flutter imports:

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/domain/constants/preferences_flags.dart';

// CONSTANT

class PreferencesService {
  final persistentsKey = [PreferencesFlag.ratingTimer, PreferencesFlag.hasRatingBeenRequested];
  late SharedPreferences _prefs;

  Future<bool> setBool(PreferencesFlag flag, {required bool value}) {
    return _prefs.setBool(flag.toString(), value);
  }

  Future<bool> setString(PreferencesFlag flag, String value) {
    return _prefs.setString(flag.toString(), value);
  }

  Future<bool> setDynamicString(PreferencesFlag flag, String key, String value) {
    return _prefs.setString('${flag}_$key', value);
  }

  /// Get persitent flags and reput them in the cache once the clear is done
  void clearWithoutPersistentKey() {
    final Map<PreferencesFlag, dynamic> allPersistentPrefs = {};

    // Save the persistent flags
    for (final flag in persistentsKey) {
      final value = _prefs.get(flag.toString());

      if (value != null) {
        allPersistentPrefs[flag] = value;
      }
    }

    // Clear the cache
    _prefs.clear();

    // Put the persistent flags back in the preferences
    allPersistentPrefs.forEach((key, value) {
      if (value is bool) {
        setBool(key, value: value);
      } else if (value is String) {
        setString(key, value);
      }
    });
  }

  Object? getPreferencesFlag(PreferencesFlag flag) {
    return _prefs.get(flag.toString());
  }

  Future<bool> removePreferencesFlag(PreferencesFlag flag) {
    return _prefs.remove(flag.toString());
  }

  Future<bool> removeDynamicPreferencesFlag(PreferencesFlag flag, String key) {
    return _prefs.remove('${flag}_$key');
  }

  Future<bool> setInt(PreferencesFlag flag, int value) async {
    return _prefs.setInt(flag.toString(), value);
  }

  Future<bool> setDateTime(PreferencesFlag flag, DateTime value) async {
    return _prefs.setString(flag.toString(), value.toIso8601String());
  }

  bool? getBool(PreferencesFlag flag) {
    return _prefs.getBool(flag.toString());
  }

  int? getInt(PreferencesFlag flag) {
    return _prefs.getInt(flag.toString());
  }

  String? getString(PreferencesFlag flag) {
    return _prefs.getString(flag.toString());
  }

  Future<String?> getDynamicString(PreferencesFlag flag, String key) async {
    return _prefs.getString('${flag}_$key');
  }

  DateTime? getDateTime(PreferencesFlag flag) {
    final flagPreference = _prefs.getString(flag.toString());

    if (flagPreference != null) {
      return DateTime.parse(flagPreference);
    }

    return null;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
}
