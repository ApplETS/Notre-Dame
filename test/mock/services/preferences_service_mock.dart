// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/services/preferences_service.dart';

import 'preferences_service_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<PreferencesService>()])
class PreferencesServiceMock extends MockPreferencesService {
  /// Stub the answer of [setString] when the [flag] is used.
  static void stubSetString(PreferencesServiceMock mock, PreferencesFlag flag,
      {bool toReturn = true}) {
    when(mock.setString(flag, any)).thenAnswer((_) async => toReturn);
  }

  /// Stub the answer of [setInt] when the [flag] is used.
  static void stubSetInt(PreferencesServiceMock mock, PreferencesFlag flag,
      {bool toReturn = true}) {
    when(mock.setInt(flag, any)).thenAnswer((_) async => toReturn);
  }

  /// Stub the answer of [setBool] when the [flag] is used.
  static void stubSetBool(PreferencesServiceMock mock, PreferencesFlag flag,
      {bool toReturn = true}) {
    when(mock.setBool(flag, value: anyNamed("value")))
        .thenAnswer((_) async => toReturn);
  }

  /// Stub the answer of [getString] when the [flag] is used.
  static void stubGetString(PreferencesServiceMock mock, PreferencesFlag flag,
      {String toReturn = "test"}) {
    when(mock.getString(flag)).thenAnswer((_) async => toReturn);
  }

  /// Stub the answer of [getString] when the [flag] is used.
  static void stubGetInt(PreferencesServiceMock mock, PreferencesFlag flag,
      {int toReturn = 1}) {
    when(mock.getInt(flag)).thenAnswer((_) async => toReturn);
  }

  /// Stub the answer of [getBool] when the [flag] is used.
  static void stubGetBool(PreferencesServiceMock mock, PreferencesFlag flag,
      {bool toReturn = true}) {
    when(mock.getBool(flag)).thenAnswer((_) async => toReturn);
  }

  /// Stub the answer of [getDateTime] when the [flag] is used.
  static void stubGetDateTime(PreferencesServiceMock mock, PreferencesFlag flag,
      {DateTime? toReturn}) {
    when(mock.getDateTime(flag)).thenAnswer((_) async => toReturn);
  }

  /// Stub the answer of [getPreferencesFlag] when the [flag] is used.
  static void stubGetPreferencesFlag(
      PreferencesServiceMock mock, PreferencesFlag flag,
      {Object? toReturn}) {
    when(mock.getPreferencesFlag(flag)).thenAnswer((_) async => toReturn);
  }

  /// Stub to throw an [Exception] when the getInt
  /// will be called with this [flag]
  static void stubException(PreferencesServiceMock mock, PreferencesFlag flag,
      {bool toReturn = true}) {
    when(mock.getInt(flag)).thenThrow(Exception());
  }
}
