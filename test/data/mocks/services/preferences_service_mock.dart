// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/preferences_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'preferences_service_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<PreferencesService>()])
class PreferencesServiceMock extends MockPreferencesService {
  /// Stub the answer of [getBool] when the [flag] is used.
  static void stubGetBool(PreferencesServiceMock mock, PreferencesFlag flag, {bool? toReturn = true}) {
    when(mock.getBool(flag)).thenAnswer((_) => toReturn);
  }

  /// Stub the answer of [setBool] when the [flag] is used.
  static void stubSetBool(PreferencesServiceMock mock, PreferencesFlag flag, {bool toReturn = true}) {
    when(mock.setBool(flag, anyNamed("value"))).thenAnswer((_) async => toReturn);
  }

  /// Stub the answer of [getString] when the [flag] is used.
  static void stubGetString(PreferencesServiceMock mock, PreferencesFlag flag, {String? toReturn = "test"}) {
    when(mock.getString(flag)).thenAnswer((_) => toReturn);
  }

  /// Stub the answer of [setString] when the [flag] is used.
  static void stubSetString(PreferencesServiceMock mock, PreferencesFlag flag, {bool toReturn = true}) {
    when(mock.setString(flag, any)).thenAnswer((_) async => toReturn);
  }

  /// Stub the answer of [getDynamicString] when the [flag] is used.
  static void stubGetDynamicString(PreferencesServiceMock mock, PreferencesFlag flag, String key, {String? toReturn = "test"}) {
    when(mock.getDynamicString(flag, key)).thenAnswer((_) => toReturn);
  }

  /// Stub the answer of [setDynamicString] when the [flag] is used.
  static void stubSetDynamicString(PreferencesServiceMock mock, PreferencesFlag flag, String key, {bool toReturn = true}) {
    when(mock.setDynamicString(flag, key, anyNamed("value"))).thenAnswer((_) async => toReturn);
  }

  /// Stub to throw an [Exception] when the getInt
  /// will be called with this [flag]
  static void stubException(PreferencesServiceMock mock, PreferencesFlag flag, {bool? toReturn = true}) {
    when(mock.getString(flag)).thenThrow(Exception());
  }
}
