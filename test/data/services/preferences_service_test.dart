// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/data/services/preferences_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import '../../helpers.dart';

void main() {
  late SharedPreferences sharedPreferences;
  late PreferencesService service;

  TestWidgetsFlutterBinding.ensureInitialized();

  group("PreferencesService - ", () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});

      setupAnalyticsServiceMock();

      service = PreferencesService();
      await service.initialize();

      sharedPreferences = await SharedPreferences.getInstance();
    });

    group("getters - ", () {
      test("getBool", () async {
        SharedPreferences.setMockInitialValues({PreferencesFlag.scheduleListView.toString(): true});
        await service.initialize();

        expect(service.getBool(PreferencesFlag.scheduleListView), isTrue);
      });

      test("getString", () async {
        SharedPreferences.setMockInitialValues({PreferencesFlag.scheduleCalendarFormat.toString(): "Test"});
        await service.initialize();

        expect(service.getString(PreferencesFlag.scheduleCalendarFormat), "Test");
      });

      test("getDynamicString", () async {
        SharedPreferences.setMockInitialValues({"${PreferencesFlag.scheduleLaboratoryGroup}_GEN101": "Test"});
        await service.initialize();

        expect(service.getDynamicString(PreferencesFlag.scheduleLaboratoryGroup, "GEN101"), "Test");
      });
    });

    group("setters - ", () {
      test("setBool", () async {
        expect(await service.setBool(PreferencesFlag.scheduleCalendarFormat, true), isTrue);
        expect(sharedPreferences.getBool(PreferencesFlag.scheduleCalendarFormat.toString()), isTrue);
      });

      test("setString", () async {
        expect(await service.setString(PreferencesFlag.scheduleCalendarFormat, "Test"), isTrue);
        expect(sharedPreferences.getString(PreferencesFlag.scheduleCalendarFormat.toString()), "Test");
      });

      test("setDynamicString", () async {
        expect(await service.setDynamicString(PreferencesFlag.scheduleLaboratoryGroup, "GEN101", "Test"), isTrue);
        expect(sharedPreferences.getString("${PreferencesFlag.scheduleLaboratoryGroup}_GEN101"), "Test");
      });

      group("setters with null values - ", () {
        test("setBool", () async {
          expect(await service.setBool(PreferencesFlag.scheduleCalendarFormat, null), isTrue);
          expect(sharedPreferences.getBool(PreferencesFlag.scheduleCalendarFormat.toString()), isNull);
        });

        test("setString", () async {
          expect(await service.setString(PreferencesFlag.scheduleCalendarFormat, null), isTrue);
          expect(sharedPreferences.getString(PreferencesFlag.scheduleCalendarFormat.toString()), isNull);
        });

        test("setDynamicString", () async {
          expect(await service.setDynamicString(PreferencesFlag.scheduleLaboratoryGroup, "GEN101", null), isTrue);
          expect(sharedPreferences.getString("${PreferencesFlag.scheduleLaboratoryGroup}_GEN101"), isNull);
        });
      });
    });

    test("clearWithoutPersistentKey", () async {
      SharedPreferences.setMockInitialValues({
        PreferencesFlag.scheduleListView.toString(): true,
        PreferencesFlag.hasRatingBeenRequested.toString(): true,
      });

      await service.initialize();

      expect(service.getBool(PreferencesFlag.scheduleListView), isTrue);

      service.clearWithoutPersistentKey();

      expect(service.getBool(PreferencesFlag.scheduleListView), isNull);
      expect(service.getBool(PreferencesFlag.hasRatingBeenRequested), isTrue);
    });
  });
}
