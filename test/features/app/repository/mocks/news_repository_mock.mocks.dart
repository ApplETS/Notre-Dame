// Mocks generated by Mockito 5.4.4 from annotations
// in notredame/test/features/app/repository/mocks/news_repository_mock.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes

// Dart imports:
import 'dart:async' as _i3;

// Package imports:
import 'package:ets_api_clients/models.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;

// Project imports:
import 'package:notredame/features/app/repository/news_repository.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [NewsRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockNewsRepository extends _i1.Mock implements _i2.NewsRepository {
  @override
  _i3.Future<_i4.PaginatedNews?> getNews({
    int? pageNumber = 1,
    int? pageSize = 3,
    String? organizerId,
    String? title,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getNews,
          [],
          {
            #pageNumber: pageNumber,
            #pageSize: pageSize,
            #organizerId: organizerId,
            #title: title,
          },
        ),
        returnValue: _i3.Future<_i4.PaginatedNews?>.value(),
        returnValueForMissingStub: _i3.Future<_i4.PaginatedNews?>.value(),
      ) as _i3.Future<_i4.PaginatedNews?>);
}
