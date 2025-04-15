// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/user_repository.dart';
import 'package:notredame/data/services/signets-api/models/profile_student.dart';
import 'package:notredame/data/services/signets-api/models/program.dart';
import 'package:notredame/utils/api_exception.dart';
import 'user_repository_mock.mocks.dart';

/// Mock for the [UserRepository]
@GenerateNiceMocks([MockSpec<UserRepository>()])
class UserRepositoryMock extends MockUserRepository {
  /// Stub the getter [ProfileStudent] of [mock] when called will return [toReturn].
  static void stubProfileStudent(UserRepositoryMock mock, {ProfileStudent? toReturn}) {
    when(mock.info).thenReturn(toReturn);
  }

  /// Stub the function [getInfo] of [mock] when called will return [toReturn].
  static void stubGetInfo(UserRepositoryMock mock, {required ProfileStudent toReturn, bool? fromCacheOnly}) {
    when(mock.getInfo(fromCacheOnly: fromCacheOnly ?? anyNamed("fromCacheOnly")))
        // ignore: cast_nullable_to_non_nullable
        .thenAnswer((_) async => toReturn);
  }

  /// Stub the function [getInfo] of [mock] when called will throw [toThrow].
  static void stubGetInfoException(UserRepositoryMock mock,
      {Exception toThrow = const ApiException(prefix: 'ApiException'), bool? fromCacheOnly}) {
    when(mock.getInfo(fromCacheOnly: fromCacheOnly ?? anyNamed("fromCacheOnly")))
        .thenAnswer((_) => Future.delayed(const Duration(milliseconds: 50)).then((value) => throw toThrow));
  }

  /// Stub the getter [coursesActivities] of [mock] when called will return [toReturn].
  static void stubPrograms(UserRepositoryMock mock, {List<Program> toReturn = const []}) {
    when(mock.programs).thenReturn(toReturn);
  }

  /// Stub the function [getPrograms] of [mock] when called will return [toReturn].
  static void stubGetPrograms(UserRepositoryMock mock, {List<Program> toReturn = const [], bool? fromCacheOnly}) {
    when(mock.getPrograms(fromCacheOnly: fromCacheOnly ?? anyNamed("fromCacheOnly"))).thenAnswer((_) async => toReturn);
  }

  /// Stub the function [getPrograms] of [mock] when called will throw [toThrow].
  static void stubGetProgramsException(UserRepositoryMock mock,
      {Exception toThrow = const ApiException(prefix: 'ApiException'), bool? fromCacheOnly}) {
    when(mock.getPrograms(fromCacheOnly: fromCacheOnly ?? anyNamed("fromCacheOnly")))
        .thenAnswer((_) => Future.delayed(const Duration(milliseconds: 50)).then((value) => throw toThrow));
  }

  /// Stub the function [logOut] of [mock] when called will return [toReturn].
  static void stubLogOut(UserRepositoryMock mock, {bool toReturn = true}) {
    when(mock.logOut()).thenAnswer((_) async => toReturn);
  }

  static void stubWasPreviouslyLoggedIn(UserRepositoryMock mock, {bool toReturn = true}) {
    when(mock.wasPreviouslyLoggedIn()).thenAnswer((_) async => toReturn);
  }
}
