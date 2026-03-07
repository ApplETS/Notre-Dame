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

  SharedPreferences.setMockInitialValues({});
  TestWidgetsFlutterBinding.ensureInitialized();

  group("PreferencesService - ", () {
    setUp(() async {
      sharedPreferences = await SharedPreferences.getInstance();
      setupAnalyticsServiceMock();
      service = PreferencesService();
      service.initialize();
    });

    group("getters - ", () {
      test("getBool", () {
        SharedPreferences.setMockInitialValues({PreferencesFlag.scheduleListView.toString(): true});

        expect(service.getBool(PreferencesFlag.scheduleListView), isTrue);
      });

      test("getString", () {
        SharedPreferences.setMockInitialValues({PreferencesFlag.scheduleCalendarFormat.toString(): "Test"});

        expect(service.getString(PreferencesFlag.scheduleCalendarFormat), "Test");
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
    });

    test("clear", () async {
      SharedPreferences.setMockInitialValues({PreferencesFlag.scheduleCalendarFormat.toString(): true});

      expect(service.getBool(PreferencesFlag.scheduleCalendarFormat), isTrue);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();

      expect(service.getBool(PreferencesFlag.scheduleCalendarFormat), null);
    });

    test("clearWithoutPersistentKey", () {
      SharedPreferences.setMockInitialValues({PreferencesFlag.scheduleCalendarFormat.toString(): true});

      expect(service.getBool(PreferencesFlag.scheduleCalendarFormat), isTrue);

      service.clearWithoutPersistentKey();

      expect(service.getBool(PreferencesFlag.scheduleCalendarFormat), null);
    });
  });
}
