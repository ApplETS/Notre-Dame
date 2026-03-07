// Flutter imports:

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/domain/constants/preferences_flags.dart';

class PreferencesService {
  final persistentsKey = [PreferencesFlag.ratingTimer, PreferencesFlag.hasRatingBeenRequested];
  late SharedPreferences _prefs;

  Future<bool> setBool(PreferencesFlag flag, bool value) {
    return _prefs.setBool(flag.toString(), value);
  }

  Future<bool> setString(PreferencesFlag flag, String? value) {
    if (value == null) {
      return removePreferencesFlag(flag);
    }

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
        setBool(key, value);
      } else if (value is String) {
        setString(key, value);
      }
    });
  }

  Future<bool> removePreferencesFlag(PreferencesFlag flag) {
    return _prefs.remove(flag.toString());
  }

  Future<bool> removeDynamicPreferencesFlag(PreferencesFlag flag, String key) {
    return _prefs.remove('${flag}_$key');
  }

  bool? getBool(PreferencesFlag flag) {
    return _prefs.getBool(flag.toString());
  }

  String? getString(PreferencesFlag flag) {
    return _prefs.getString(flag.toString());
  }

  String? getDynamicString(PreferencesFlag flag, String key) {
    return _prefs.getString('${flag}_$key');
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
}
