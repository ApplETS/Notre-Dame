// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/locator.dart';

class PreferencesService {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  static const String _tag = "PreferencesService";

  final _persistentsKey = [PreferencesFlag.ratingTimer, PreferencesFlag.hasRatingBeenRequested];
  late SharedPreferences _prefs;

  bool? getBool(PreferencesFlag flag) {
    _analyticsService.logEvent("${_tag}_${flag.name}", 'getBool');

    return _prefs.getBool(flag.toString());
  }

  Future<bool> setBool(PreferencesFlag flag, bool? value) {
    _analyticsService.logEvent("${_tag}_${flag.name}", 'setBool');

    if (value == null) {
      return _removePreferencesFlag(flag);
    }

    return _prefs.setBool(flag.toString(), value);
  }

  String? getString(PreferencesFlag flag) {
    _analyticsService.logEvent("${_tag}_${flag.name}", 'getString');

    return _prefs.getString(flag.toString());
  }

  Future<bool> setString(PreferencesFlag flag, String? value) {
    _analyticsService.logEvent("${_tag}_${flag.name}", 'setString');

    if (value == null) {
      return _removePreferencesFlag(flag);
    }

    return _prefs.setString(flag.toString(), value);
  }

  String? getDynamicString(PreferencesFlag flag, String key) {
    _analyticsService.logEvent("${_tag}_${flag.name}", 'getDynamicString');

    return _prefs.getString('${flag}_$key');
  }

  Future<bool> setDynamicString(PreferencesFlag flag, String key, String? value) {
    _analyticsService.logEvent("${_tag}_${flag.name}", 'setDynamicString');

    if (value == null) {
      return _prefs.remove('${flag}_$key');
    }

    return _prefs.setString('${flag}_$key', value);
  }

  /// Get persitent flags and reput them in the cache once the clear is done
  void clearWithoutPersistentKey() {
    final Map<PreferencesFlag, dynamic> allPersistentPrefs = {};

    // Save the persistent flags
    for (final flag in _persistentsKey) {
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

  Future<bool> _removePreferencesFlag(PreferencesFlag flag) {
    return _prefs.remove(flag.toString());
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
}
