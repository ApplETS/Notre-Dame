// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/services/preferences_service.dart';

void main() {
  late SharedPreferences sharedPreferences;

  late PreferencesService service;

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
            await service.setBool(PreferencesFlag.scheduleCalendarFormat,
                value: true),
            isTrue);
        expect(
            sharedPreferences
                .getBool(PreferencesFlag.scheduleCalendarFormat.toString()),
            isTrue);
      });

      test("setString", () async {
        expect(
            await service.setString(
                PreferencesFlag.scheduleCalendarFormat, "Test"),
            isTrue);
        expect(
            sharedPreferences
                .getString(PreferencesFlag.scheduleCalendarFormat.toString()),
            "Test");
      });

      test("setInt", () async {
        expect(await service.setInt(PreferencesFlag.scheduleCalendarFormat, 1),
            isTrue);
        expect(
            sharedPreferences
                .getInt(PreferencesFlag.scheduleCalendarFormat.toString()),
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
          {PreferencesFlag.scheduleCalendarFormat.toString(): true});

      expect(await service.getBool(PreferencesFlag.scheduleCalendarFormat),
          isTrue);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();

      expect(
          await service.getBool(PreferencesFlag.scheduleCalendarFormat), null);
    });

    test("clearWithoutPersistentKey", () async {
      SharedPreferences.setMockInitialValues({
        PreferencesFlag.scheduleCalendarFormat.toString(): true,
        PreferencesFlag.discoveryDashboard.toString(): true
      });

      expect(await service.getBool(PreferencesFlag.scheduleCalendarFormat),
          isTrue);
      expect(await service.getBool(PreferencesFlag.discoveryDashboard), isTrue);

      service.clearWithoutPersistentKey();

      expect(
          await service.getBool(PreferencesFlag.scheduleCalendarFormat), null);

      expect(await service.getBool(PreferencesFlag.discoveryDashboard), isTrue);
    });

    group("getters - ", () {
      test("get", () async {
        SharedPreferences.setMockInitialValues(
            {PreferencesFlag.scheduleCalendarFormat.toString(): true});

        expect(
            await service
                .getPreferencesFlag(PreferencesFlag.scheduleCalendarFormat),
            isInstanceOf<bool>());
      });

      test("getBool", () async {
        SharedPreferences.setMockInitialValues(
            {PreferencesFlag.scheduleCalendarFormat.toString(): true});

        expect(await service.getBool(PreferencesFlag.scheduleCalendarFormat),
            isTrue);
      });

      test("getString", () async {
        SharedPreferences.setMockInitialValues(
            {PreferencesFlag.scheduleCalendarFormat.toString(): "Test"});

        expect(await service.getString(PreferencesFlag.scheduleCalendarFormat),
            "Test");
      });

      test("getInt", () async {
        SharedPreferences.setMockInitialValues(
            {PreferencesFlag.scheduleCalendarFormat.toString(): 1});

        expect(await service.getInt(PreferencesFlag.scheduleCalendarFormat), 1);
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
