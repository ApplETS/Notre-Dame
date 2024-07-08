// Mocks generated by Mockito 5.4.4 from annotations
// in notredame/test/features/app/repository/mocks/course_repository_mock.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:ets_api_clients/models.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:notredame/features/app/repository/course_repository.dart'
    as _i3;

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

class _FakeCourse_0 extends _i1.SmartFake implements _i2.Course {
  _FakeCourse_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [CourseRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockCourseRepository extends _i1.Mock implements _i3.CourseRepository {
  @override
  List<_i2.Session> get activeSessions => (super.noSuchMethod(
        Invocation.getter(#activeSessions),
        returnValue: <_i2.Session>[],
        returnValueForMissingStub: <_i2.Session>[],
      ) as List<_i2.Session>);

  @override
  _i4.Future<List<_i2.CourseActivity>?> getCoursesActivities(
          {bool? fromCacheOnly = false}) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCoursesActivities,
          [],
          {#fromCacheOnly: fromCacheOnly},
        ),
        returnValue: _i4.Future<List<_i2.CourseActivity>?>.value(),
        returnValueForMissingStub:
            _i4.Future<List<_i2.CourseActivity>?>.value(),
      ) as _i4.Future<List<_i2.CourseActivity>?>);

  @override
  _i4.Future<List<_i2.ScheduleActivity>> getDefaultScheduleActivities({
    String? session,
    bool? fromCacheOnly = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getDefaultScheduleActivities,
          [],
          {
            #session: session,
            #fromCacheOnly: fromCacheOnly,
          },
        ),
        returnValue: _i4.Future<List<_i2.ScheduleActivity>>.value(
            <_i2.ScheduleActivity>[]),
        returnValueForMissingStub: _i4.Future<List<_i2.ScheduleActivity>>.value(
            <_i2.ScheduleActivity>[]),
      ) as _i4.Future<List<_i2.ScheduleActivity>>);

  @override
  _i4.Future<List<_i2.ScheduleActivity>> getScheduleActivities(
          {bool? fromCacheOnly = false}) =>
      (super.noSuchMethod(
        Invocation.method(
          #getScheduleActivities,
          [],
          {#fromCacheOnly: fromCacheOnly},
        ),
        returnValue: _i4.Future<List<_i2.ScheduleActivity>>.value(
            <_i2.ScheduleActivity>[]),
        returnValueForMissingStub: _i4.Future<List<_i2.ScheduleActivity>>.value(
            <_i2.ScheduleActivity>[]),
      ) as _i4.Future<List<_i2.ScheduleActivity>>);

  @override
  _i4.Future<List<_i2.Session>> getSessions() => (super.noSuchMethod(
        Invocation.method(
          #getSessions,
          [],
        ),
        returnValue: _i4.Future<List<_i2.Session>>.value(<_i2.Session>[]),
        returnValueForMissingStub:
            _i4.Future<List<_i2.Session>>.value(<_i2.Session>[]),
      ) as _i4.Future<List<_i2.Session>>);

  @override
  _i4.Future<List<_i2.Course>> getCourses({bool? fromCacheOnly = false}) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCourses,
          [],
          {#fromCacheOnly: fromCacheOnly},
        ),
        returnValue: _i4.Future<List<_i2.Course>>.value(<_i2.Course>[]),
        returnValueForMissingStub:
            _i4.Future<List<_i2.Course>>.value(<_i2.Course>[]),
      ) as _i4.Future<List<_i2.Course>>);

  @override
  _i4.Future<_i2.Course> getCourseSummary(_i2.Course? course) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCourseSummary,
          [course],
        ),
        returnValue: _i4.Future<_i2.Course>.value(_FakeCourse_0(
          this,
          Invocation.method(
            #getCourseSummary,
            [course],
          ),
        )),
        returnValueForMissingStub: _i4.Future<_i2.Course>.value(_FakeCourse_0(
          this,
          Invocation.method(
            #getCourseSummary,
            [course],
          ),
        )),
      ) as _i4.Future<_i2.Course>);
}
