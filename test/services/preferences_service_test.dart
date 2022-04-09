// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

void main() {
  SharedPreferences sharedPreferences;

  PreferencesService service;

  SharedPreferences.setMockInitialValues({});
  TestWidgetsFlutterBinding.ensureInitialized();

  group("PreferencesService - ", () {
    setUp(() async {
      sharedPreferences = await SharedPreferences.getInstance();

      service = PreferencesService();
    });

    group("setters - ", () {
      test("setBool", () async {
        expect(
            await service.setBool(
                PreferencesFlag.scheduleSettingsCalendarFormat,
                value: true),
            isTrue);
        expect(
            sharedPreferences.getBool(
                PreferencesFlag.scheduleSettingsCalendarFormat.toString()),
            isTrue);
      });

      test("setString", () async {
        expect(
            await service.setString(
                PreferencesFlag.scheduleSettingsCalendarFormat, "Test"),
            isTrue);
        expect(
            sharedPreferences.getString(
                PreferencesFlag.scheduleSettingsCalendarFormat.toString()),
            "Test");
      });

      test("setInt", () async {
        expect(
            await service.setInt(
                PreferencesFlag.scheduleSettingsCalendarFormat, 1),
            isTrue);
        expect(
            sharedPreferences.getInt(
                PreferencesFlag.scheduleSettingsCalendarFormat.toString()),
            1);
      });

      test("setDateTime", () async {
        expect(
            await service.setDateTime(
                PreferencesFlag.ratingTimer, DateTime(2000, 01, 02)),
            isTrue);
        expect(
            sharedPreferences.getString(PreferencesFlag.ratingTimer.toString()),
            DateTime(2000, 01, 02).toIso8601String());
      });
    });

    test("clear", () async {
      SharedPreferences.setMockInitialValues(
          {PreferencesFlag.scheduleSettingsCalendarFormat.toString(): true});

      expect(
          await service.getBool(PreferencesFlag.scheduleSettingsCalendarFormat),
          isTrue);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();

      expect(
          await service.getBool(PreferencesFlag.scheduleSettingsCalendarFormat),
          null);
    });

    test("clearWithoutPersistentKey", () async {
      SharedPreferences.setMockInitialValues({
        PreferencesFlag.scheduleSettingsCalendarFormat.toString(): true,
        PreferencesFlag.discoveryDashboard.toString(): true
      });

      expect(
          await service.getBool(PreferencesFlag.scheduleSettingsCalendarFormat),
          isTrue);
      expect(await service.getBool(PreferencesFlag.discoveryDashboard), isTrue);

      service.clearWithoutPersistentKey();

      expect(
          await service.getBool(PreferencesFlag.scheduleSettingsCalendarFormat),
          null);

      expect(await service.getBool(PreferencesFlag.discoveryDashboard), isTrue);
    });

    group("getters - ", () {
      test("get", () async {
        SharedPreferences.setMockInitialValues(
            {PreferencesFlag.scheduleSettingsCalendarFormat.toString(): true});

        expect(
            await service.getPreferencesFlag(
                PreferencesFlag.scheduleSettingsCalendarFormat),
            isInstanceOf<bool>());
      });

      test("getBool", () async {
        SharedPreferences.setMockInitialValues(
            {PreferencesFlag.scheduleSettingsCalendarFormat.toString(): true});

        expect(
            await service
                .getBool(PreferencesFlag.scheduleSettingsCalendarFormat),
            isTrue);
      });

      test("getString", () async {
        SharedPreferences.setMockInitialValues({
          PreferencesFlag.scheduleSettingsCalendarFormat.toString(): "Test"
        });

        expect(
            await service
                .getString(PreferencesFlag.scheduleSettingsCalendarFormat),
            "Test");
      });

      test("getInt", () async {
        SharedPreferences.setMockInitialValues(
            {PreferencesFlag.scheduleSettingsCalendarFormat.toString(): 1});

        expect(
            await service
                .getInt(PreferencesFlag.scheduleSettingsCalendarFormat),
            1);
      });

      test("getDateTime", () async {
        SharedPreferences.setMockInitialValues({
          PreferencesFlag.ratingTimer.toString():
              DateTime(2000, 01, 02).toIso8601String()
        });

        expect(await service.getDateTime(PreferencesFlag.ratingTimer),
            DateTime(2000, 01, 02));
      });
    });
  });
}
