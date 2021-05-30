// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';

// CONSTANT
import 'package:notredame/core/constants/preferences_flags.dart';

// SERVICE
import 'package:notredame/core/services/preferences_service.dart';

class PreferencesServiceMock extends Mock implements PreferencesService {
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

  /// Stub to throw an [Exception] when the getInt
  /// will be called with this [flag]
  static void stubException(PreferencesServiceMock mock, PreferencesFlag flag,
      {bool toReturn = true}) {
    when(mock.getInt(flag)).thenThrow(Exception());
  }
}
