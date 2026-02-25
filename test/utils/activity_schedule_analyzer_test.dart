// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/utils/activity_schedule_analyzer.dart';

void main() {
  DateTime weekday(DateTime reference, int targetWeekday, {int week = 0, int hour = 0, int minute = 0}) {
    final startOfWeek = reference.subtract(Duration(days: reference.weekday - DateTime.monday));
    final target = startOfWeek.add(Duration(days: (week * 7) + (targetWeekday - DateTime.monday)));
    return DateTime(target.year, target.month, target.day, hour, minute);
  }

  CourseActivity createActivity(DateTime start, {Duration duration = const Duration(hours: 2), String activityName = 'Cours'}) {
    return CourseActivity(
      courseGroup: 'LOG430-01',
      courseName: 'Architecture logicielle',
      activityName: activityName,
      activityDescription: 'Cours magistral',
      activityLocation: ['A-1234'],
      startDateTime: start,
      endDateTime: start.add(duration),
    );
  }

  List<CourseActivity> createWeekActivities(DateTime monday) {
    return [
      createActivity(monday.add(const Duration(hours: 9))),
      createActivity(monday.add(const Duration(days: 1, hours: 9))),
      createActivity(monday.add(const Duration(days: 2, hours: 9))),
      createActivity(monday.add(const Duration(days: 3, hours: 9))),
      createActivity(monday.add(const Duration(days: 4, hours: 9))),
    ];
  }

  group('ActivityScheduleAnalyzer -', () {
    final reference = DateTime(2024, 3, 4);

    group('getActivitiesInRange -', () {
      test('returns activities within range', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = createWeekActivities(monday);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        final result = analyzer.getActivitiesInRange(monday, weekday(reference, DateTime.thursday));

        expect(result.length, 3);
      });

      test('returns empty list when no activities in range', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = createWeekActivities(monday);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        final result = analyzer.getActivitiesInRange(
          weekday(reference, DateTime.monday, week: 1),
          weekday(reference, DateTime.monday, week: 2),
        );

        expect(result, isEmpty);
      });

      test('includes activities starting at range start, excludes at range end', () {
        final monday = weekday(reference, DateTime.monday, hour: 9);
        final activity = createActivity(monday);
        final analyzer = ScheduleAnalyzer(courseActivities: [activity], now: monday);

        expect(analyzer.getActivitiesInRange(monday, weekday(reference, DateTime.tuesday)), contains(activity));

        expect(analyzer.getActivitiesInRange(weekday(reference, DateTime.sunday, week: -1), monday), isEmpty);
      });
    });

    group('getUniqueDays -', () {
      test('returns unique days sorted', () {
        final monday = weekday(reference, DateTime.monday, hour: 9);
        final tuesday = weekday(reference, DateTime.tuesday, hour: 9);
        final activities = [
          createActivity(monday),
          createActivity(monday.add(const Duration(hours: 2))),
          createActivity(tuesday),
        ];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        final result = analyzer.getUniqueDays(activities);

        expect(result.length, 2);
        expect(result[0].day, monday.day);
        expect(result[1].day, tuesday.day);
      });

      test('returns empty list for empty activities', () {
        final monday = weekday(reference, DateTime.monday);
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: monday);

        expect(analyzer.getUniqueDays([]), isEmpty);
      });
    });

    group('hasNextWeekSchedule -', () {
      test('returns true when next week has activities', () {
        final monday = weekday(reference, DateTime.monday);
        final nextMonday = weekday(reference, DateTime.monday, week: 1);
        final activities = [...createWeekActivities(monday), ...createWeekActivities(nextMonday)];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.hasNextWeekSchedule, isTrue);
      });

      test('returns false when next week has no activities', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = createWeekActivities(monday);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.hasNextWeekSchedule, isFalse);
      });
    });

    group('isAfterLastCourseOfWeek -', () {
      test('returns true when after last course', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = createWeekActivities(monday);

        final now = weekday(reference, DateTime.friday, hour: 15);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

        expect(analyzer.isAfterLastCourseOfWeek, isTrue);
      });

      test('returns false when before last course ends', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = createWeekActivities(monday);

        final now = weekday(reference, DateTime.friday, hour: 10);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

        expect(analyzer.isAfterLastCourseOfWeek, isFalse);
      });

      test('returns true when now equals exact end time of last course', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = createWeekActivities(monday);

        // Last activity starts Friday at 9:00 with 2h duration, ends at 11:00
        final now = weekday(reference, DateTime.friday, hour: 11);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

        expect(analyzer.isAfterLastCourseOfWeek, isTrue);
      });

      test('returns false when no activities this week', () {
        final monday = weekday(reference, DateTime.monday);
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: monday);

        expect(analyzer.isAfterLastCourseOfWeek, isFalse);
      });
    });

    group('isLastCourseDayOfWeek -', () {
      test('returns true on the last day with courses', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = createWeekActivities(monday);

        final now = weekday(reference, DateTime.friday, hour: 10);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

        expect(analyzer.isLastCourseDayOfWeek, isTrue);
      });

      test('returns false on a day before the last course day', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = createWeekActivities(monday);

        final now = weekday(reference, DateTime.thursday, hour: 10);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

        expect(analyzer.isLastCourseDayOfWeek, isFalse);
      });

      test('returns true when only one course day and its today', () {
        final activities = [createActivity(weekday(reference, DateTime.monday, hour: 9))];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: weekday(reference, DateTime.monday, hour: 10));

        expect(analyzer.isLastCourseDayOfWeek, isTrue);
      });

      test('returns false on a weekend day with no courses', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = createWeekActivities(monday);

        final now = weekday(reference, DateTime.saturday, hour: 10);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

        expect(analyzer.isLastCourseDayOfWeek, isFalse);
      });

      test('returns false when no activities this week', () {
        final monday = weekday(reference, DateTime.monday);
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: monday);

        expect(analyzer.isLastCourseDayOfWeek, isFalse);
      });
    });

    group('isNextWeekShorter -', () {
      test('returns true when next week has fewer than 5 course days', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = [
          ...createWeekActivities(monday),

          createActivity(weekday(reference, DateTime.monday, week: 1, hour: 9)),
          createActivity(weekday(reference, DateTime.tuesday, week: 1, hour: 9)),
          createActivity(weekday(reference, DateTime.wednesday, week: 1, hour: 9)),
        ];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.isNextWeekShorter, isTrue);
      });

      test('returns false when next week has 5 course days', () {
        final monday = weekday(reference, DateTime.monday);
        final nextMonday = weekday(reference, DateTime.monday, week: 1);
        final activities = [...createWeekActivities(monday), ...createWeekActivities(nextMonday)];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.isNextWeekShorter, isFalse);
      });

      test('returns true when next week has no activities', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = createWeekActivities(monday);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.isNextWeekShorter, isTrue);
      });
    });

    group('courseDaysThisWeek -', () {
      test('returns number of unique course days', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = createWeekActivities(monday);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.courseDaysThisWeek, 5);
      });

      test('counts multiple activities on same day as one day', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = [
          createActivity(weekday(reference, DateTime.monday, hour: 9)),
          createActivity(weekday(reference, DateTime.monday, hour: 13)),
          createActivity(weekday(reference, DateTime.tuesday, hour: 9)),
        ];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.courseDaysThisWeek, 2);
      });

      test('returns 0 when no activities this week', () {
        final monday = weekday(reference, DateTime.monday);
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: monday);

        expect(analyzer.courseDaysThisWeek, 0);
      });
    });

    group('calculateUsualWeekendGapDays -', () {
      test('returns default when less than 2 activities', () {
        final monday = weekday(reference, DateTime.monday);
        final analyzer = ScheduleAnalyzer(
          courseActivities: [createActivity(weekday(reference, DateTime.monday, hour: 9))],
          now: monday,
        );

        expect(
          analyzer.calculateUsualWeekendGapDays(
            excludeStart: monday,
            excludeEnd: weekday(reference, DateTime.monday, week: 1),
          ),
          3,
        );
      });

      test('calculates median gap across weeks', () {
        final activities = [
          createActivity(weekday(reference, DateTime.tuesday, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, hour: 9)),

          createActivity(weekday(reference, DateTime.monday, week: 1, hour: 9)),
          createActivity(weekday(reference, DateTime.thursday, week: 1, hour: 9)),

          createActivity(weekday(reference, DateTime.tuesday, week: 2, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 2, hour: 9)),

          createActivity(weekday(reference, DateTime.monday, week: 3, hour: 9)),
          createActivity(weekday(reference, DateTime.thursday, week: 3, hour: 9)),

          createActivity(weekday(reference, DateTime.monday, week: 4, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 4, hour: 9)),

          createActivity(weekday(reference, DateTime.tuesday, week: 5, hour: 9)),
          createActivity(weekday(reference, DateTime.thursday, week: 5, hour: 9)),
        ];
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.monday, week: 2, hour: 9),
        );

        expect(
          analyzer.calculateUsualWeekendGapDays(
            excludeStart: weekday(reference, DateTime.monday, week: 10),
            excludeEnd: weekday(reference, DateTime.monday, week: 11),
          ),
          4,
        );
      });

      test('excludes specified gap from calculation', () {
        final activities = [
          createActivity(weekday(reference, DateTime.tuesday, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, hour: 9)),

          createActivity(weekday(reference, DateTime.monday, week: 1, hour: 9)),
          createActivity(weekday(reference, DateTime.wednesday, week: 1, hour: 9)),

          createActivity(weekday(reference, DateTime.tuesday, week: 2, hour: 9)),
          createActivity(weekday(reference, DateTime.thursday, week: 2, hour: 9)),

          createActivity(weekday(reference, DateTime.tuesday, week: 3, hour: 9)),
          createActivity(weekday(reference, DateTime.thursday, week: 3, hour: 9)),
        ];
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.thursday, week: 2, hour: 9),
        );

        final result = analyzer.calculateUsualWeekendGapDays(
          excludeStart: weekday(reference, DateTime.wednesday, week: 1),
          excludeEnd: weekday(reference, DateTime.tuesday, week: 2),
        );

        expect(result, 3);
      });
    });

    group('isLongWeekendIncoming -', () {
      test('returns true when next gap is longer than usual with many weeks of data', () {
        final activities = [
          createActivity(weekday(reference, DateTime.monday, hour: 9)),
          createActivity(weekday(reference, DateTime.wednesday, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, hour: 9)),

          createActivity(weekday(reference, DateTime.monday, week: 1, hour: 9)),
          createActivity(weekday(reference, DateTime.wednesday, week: 1, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 1, hour: 9)),

          createActivity(weekday(reference, DateTime.monday, week: 2, hour: 9)),
          createActivity(weekday(reference, DateTime.wednesday, week: 2, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 2, hour: 9)),

          createActivity(weekday(reference, DateTime.monday, week: 3, hour: 9)),
          createActivity(weekday(reference, DateTime.wednesday, week: 3, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 3, hour: 9)),

          createActivity(weekday(reference, DateTime.monday, week: 4, hour: 9)),
          createActivity(weekday(reference, DateTime.wednesday, week: 4, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 4, hour: 9)),

          createActivity(weekday(reference, DateTime.wednesday, week: 5, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 5, hour: 9)),
        ];

        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.thursday, week: 4, hour: 10),
        );

        expect(analyzer.isLongWeekendIncoming, isTrue);
      });

      test('returns true for Tuesday/Thursday pattern with Monday holiday', () {
        // Weeks 0-4: Tue/Thu pattern (usual gap: 4 days, Thu→Tue)
        // Week 5: no Tuesday → gap from Thu week 4 to Thu week 5 = 7 days
        final activities = [
          createActivity(weekday(reference, DateTime.tuesday, hour: 9)),
          createActivity(weekday(reference, DateTime.thursday, hour: 9)),

          createActivity(weekday(reference, DateTime.tuesday, week: 1, hour: 9)),
          createActivity(weekday(reference, DateTime.thursday, week: 1, hour: 9)),

          createActivity(weekday(reference, DateTime.tuesday, week: 2, hour: 9)),
          createActivity(weekday(reference, DateTime.thursday, week: 2, hour: 9)),

          createActivity(weekday(reference, DateTime.tuesday, week: 3, hour: 9)),
          createActivity(weekday(reference, DateTime.thursday, week: 3, hour: 9)),

          createActivity(weekday(reference, DateTime.tuesday, week: 4, hour: 9)),
          createActivity(weekday(reference, DateTime.thursday, week: 4, hour: 9)),

          createActivity(weekday(reference, DateTime.thursday, week: 5, hour: 9)),
        ];

        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.wednesday, week: 4, hour: 10),
        );

        expect(analyzer.isLongWeekendIncoming, isTrue);
      });

      test('returns false when gap matches usual pattern across many weeks', () {
        final activities = [
          for (int week = 0; week < 6; week++) ...[
            createActivity(weekday(reference, DateTime.monday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.wednesday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.friday, week: week, hour: 9)),
          ],
        ];
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.thursday, week: 4, hour: 10),
        );

        expect(analyzer.isLongWeekendIncoming, isFalse);
      });

      test('returns false when gap is normal with full week schedule', () {
        final activities = [
          for (int week = 0; week < 4; week++) ...createWeekActivities(weekday(reference, DateTime.monday, week: week)),
        ];
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.friday, week: 1, hour: 10),
        );

        expect(analyzer.isLongWeekendIncoming, isFalse);
      });

      test('returns false when no activities this week', () {
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: weekday(reference, DateTime.monday));

        expect(analyzer.isLongWeekendIncoming, isFalse);
      });

      test('returns true when gap to next activity is longer than usual', () {
        final activities = [
          for (int week = 0; week < 4; week++) ...[
            createActivity(weekday(reference, DateTime.monday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.friday, week: week, hour: 9)),
          ],
          createActivity(weekday(reference, DateTime.monday, week: 4, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 4, hour: 9)),

          // Week 5: empty
          createActivity(weekday(reference, DateTime.monday, week: 6, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 6, hour: 9)),
        ];
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.thursday, week: 4, hour: 10),
        );

        expect(analyzer.isLongWeekendIncoming, isTrue);
      });

      test('detects long weekend when Friday is holiday', () {
        final activities = [
          for (int week = 0; week < 4; week++) ...createWeekActivities(weekday(reference, DateTime.monday, week: week)),
          createActivity(weekday(reference, DateTime.monday, week: 4, hour: 9)),
          createActivity(weekday(reference, DateTime.tuesday, week: 4, hour: 9)),
          createActivity(weekday(reference, DateTime.wednesday, week: 4, hour: 9)),
          createActivity(weekday(reference, DateTime.thursday, week: 4, hour: 9)),
          ...createWeekActivities(weekday(reference, DateTime.monday, week: 5)),
        ];
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.wednesday, week: 4, hour: 10),
        );

        expect(analyzer.isLongWeekendIncoming, isTrue);
      });
    });

    group('isInsideLongWeekend -', () {
      test('returns true when inside long weekend with many weeks of baseline data', () {
        final activities = [
          for (int week = 0; week < 4; week++) ...[
            createActivity(weekday(reference, DateTime.monday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.wednesday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.friday, week: week, hour: 9)),
          ],
          createActivity(weekday(reference, DateTime.monday, week: 4, hour: 9)),
          createActivity(weekday(reference, DateTime.wednesday, week: 4, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 4, hour: 9)),

          createActivity(weekday(reference, DateTime.wednesday, week: 5, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 5, hour: 9)),
        ];
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.sunday, week: 4, hour: 12),
        );

        expect(analyzer.isInsideLongWeekend, isTrue);
      });

      test('returns true on Monday of long weekend when Tuesday is first class', () {
        final activities = [
          for (int week = 0; week < 4; week++) ...[
            createActivity(weekday(reference, DateTime.tuesday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.thursday, week: week, hour: 9)),
          ],
          createActivity(weekday(reference, DateTime.tuesday, week: 4, hour: 9)),
          createActivity(weekday(reference, DateTime.thursday, week: 4, hour: 9)),

          createActivity(weekday(reference, DateTime.thursday, week: 5, hour: 9)),
        ];

        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.monday, week: 5, hour: 12),
        );

        expect(analyzer.isInsideLongWeekend, isTrue);
      });

      test('returns false during normal weekend with many weeks of data', () {
        final activities = [
          for (int week = 0; week < 6; week++) ...createWeekActivities(weekday(reference, DateTime.monday, week: week)),
        ];

        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.saturday, week: 2, hour: 12),
        );

        expect(analyzer.isInsideLongWeekend, isFalse);
      });

      test('returns false on Sunday of normal Fri->Mon gap', () {
        final activities = [
          for (int week = 0; week < 5; week++) ...[
            createActivity(weekday(reference, DateTime.monday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.wednesday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.friday, week: week, hour: 9)),
          ],
        ];

        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.sunday, week: 2, hour: 12),
        );

        expect(analyzer.isInsideLongWeekend, isFalse);
      });

      test('returns false when no activities', () {
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: weekday(reference, DateTime.monday));

        expect(analyzer.isInsideLongWeekend, isFalse);
      });

      test('returns false when still in an activity', () {
        final activities = [
          for (int week = 0; week < 4; week++) ...[
            createActivity(weekday(reference, DateTime.monday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.friday, week: week, hour: 9)),
          ],
        ];

        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.monday, week: 2, hour: 10),
        );

        expect(analyzer.isInsideLongWeekend, isFalse);
      });

      test('returns false when no future activities', () {
        final activities = [
          for (int week = 0; week < 3; week++) ...[
            createActivity(weekday(reference, DateTime.monday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.friday, week: week, hour: 9)),
          ],
        ];

        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.monday, week: 10),
        );

        expect(analyzer.isInsideLongWeekend, isFalse);
      });

      test('returns true during reading week gap', () {
        final activities = [
          for (int week = 0; week < 4; week++) ...[
            createActivity(weekday(reference, DateTime.monday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.friday, week: week, hour: 9)),
          ],
          createActivity(weekday(reference, DateTime.monday, week: 4, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 4, hour: 9)),

          // Week 5: Empty
          createActivity(weekday(reference, DateTime.monday, week: 6, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 6, hour: 9)),
        ];

        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.wednesday, week: 5, hour: 12),
        );

        expect(analyzer.isInsideLongWeekend, isTrue);
      });

      test('handles multiple activities per day correctly', () {
        final activities = [
          for (int week = 0; week < 4; week++) ...[
            createActivity(weekday(reference, DateTime.monday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.monday, week: week, hour: 13)),
            createActivity(weekday(reference, DateTime.friday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.friday, week: week, hour: 13)),
          ],

          createActivity(weekday(reference, DateTime.monday, week: 4, hour: 9)),
          createActivity(weekday(reference, DateTime.monday, week: 4, hour: 13)),
          createActivity(weekday(reference, DateTime.friday, week: 4, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 4, hour: 13)),

          createActivity(weekday(reference, DateTime.monday, week: 5, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 5, hour: 9)),
        ];

        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.saturday, week: 4, hour: 12),
        );

        expect(analyzer.isInsideLongWeekend, isFalse);
      });
    });

    group('upcomingBreakDuration -', () {
      test('returns gap days when upcoming break is longer than usual', () {
        final activities = [
          for (int week = 0; week < 5; week++) ...[
            createActivity(weekday(reference, DateTime.monday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.friday, week: week, hour: 9)),
          ],
          createActivity(weekday(reference, DateTime.monday, week: 6, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 6, hour: 9)),
        ];
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.thursday, week: 4, hour: 10),
        );

        expect(analyzer.upcomingBreakDuration, isNotNull);
        expect(analyzer.upcomingBreakDuration, greaterThan(3));
      });

      test('returns null when no break is upcoming', () {
        final activities = [
          for (int week = 0; week < 4; week++) ...createWeekActivities(weekday(reference, DateTime.monday, week: week)),
        ];
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.friday, week: 1, hour: 10),
        );

        expect(analyzer.upcomingBreakDuration, isNull);
      });

      test('returns null when no activities this week', () {
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: weekday(reference, DateTime.monday));

        expect(analyzer.upcomingBreakDuration, isNull);
      });
    });

    group('daysUntilBreakStart -', () {
      test('returns days until break starts when break is upcoming', () {
        final activities = [
          for (int week = 0; week < 5; week++) ...[
            createActivity(weekday(reference, DateTime.monday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.friday, week: week, hour: 9)),
          ],
          createActivity(weekday(reference, DateTime.monday, week: 6, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 6, hour: 9)),
        ];
        final now = weekday(reference, DateTime.thursday, week: 4, hour: 10);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

        // Last activity this week is Friday, daysBetween(Thu, Fri) + 1
        expect(analyzer.daysUntilBreakStart, isNotNull);
        expect(analyzer.daysUntilBreakStart, greaterThan(0));
      });

      test('returns null when no break is upcoming', () {
        final activities = [
          for (int week = 0; week < 4; week++) ...createWeekActivities(weekday(reference, DateTime.monday, week: week)),
        ];
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.friday, week: 1, hour: 10),
        );

        expect(analyzer.daysUntilBreakStart, isNull);
      });

      test('returns 1 when on the last activity day before break', () {
        final activities = [
          for (int week = 0; week < 5; week++) ...[
            createActivity(weekday(reference, DateTime.monday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.friday, week: week, hour: 9)),
          ],
          createActivity(weekday(reference, DateTime.monday, week: 6, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 6, hour: 9)),
        ];
        final now = weekday(reference, DateTime.friday, week: 4, hour: 8);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

        expect(analyzer.daysUntilBreakStart, 1);
      });
    });

    group('daysUntilNextCourse -', () {
      test('returns days until next course when inside a long break', () {
        final activities = [
          for (int week = 0; week < 5; week++) ...[
            createActivity(weekday(reference, DateTime.monday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.friday, week: week, hour: 9)),
          ],
          createActivity(weekday(reference, DateTime.monday, week: 6, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 6, hour: 9)),
        ];
        final now = weekday(reference, DateTime.wednesday, week: 5, hour: 12);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

        // Next course is Monday week 6
        expect(analyzer.daysUntilNextCourse, isNotNull);
        expect(analyzer.daysUntilNextCourse, greaterThan(0));
      });

      test('returns null during a normal weekend', () {
        final activities = [
          for (int week = 0; week < 6; week++) ...createWeekActivities(weekday(reference, DateTime.monday, week: week)),
        ];
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.saturday, week: 2, hour: 12),
        );

        expect(analyzer.daysUntilNextCourse, isNull);
      });

      test('returns null when no activities', () {
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: weekday(reference, DateTime.monday));

        expect(analyzer.daysUntilNextCourse, isNull);
      });
    });

    group('totalBreakDuration -', () {
      test('returns total gap days when inside a long break', () {
        // Reading week gap: week 5 empty
        final activities = [
          for (int week = 0; week < 5; week++) ...[
            createActivity(weekday(reference, DateTime.monday, week: week, hour: 9)),
            createActivity(weekday(reference, DateTime.friday, week: week, hour: 9)),
          ],
          createActivity(weekday(reference, DateTime.monday, week: 6, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 6, hour: 9)),
        ];
        final now = weekday(reference, DateTime.wednesday, week: 5, hour: 12);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

        expect(analyzer.totalBreakDuration, isNotNull);
        expect(analyzer.totalBreakDuration, greaterThan(3));
      });

      test('returns null during a normal weekend', () {
        final activities = [
          for (int week = 0; week < 6; week++) ...createWeekActivities(weekday(reference, DateTime.monday, week: week)),
        ];
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: weekday(reference, DateTime.saturday, week: 2, hour: 12),
        );

        expect(analyzer.totalBreakDuration, isNull);
      });

      test('returns null when no activities', () {
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: weekday(reference, DateTime.monday));

        expect(analyzer.totalBreakDuration, isNull);
      });
    });

    group('getLastRegularCourseDate -', () {
      test('returns null when no activities exist', () {
        final monday = weekday(reference, DateTime.monday);
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: monday);

        expect(analyzer.getLastRegularCourseDate(), isNull);
      });

      test('returns null when all activities are finals', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = [
          createActivity(weekday(reference, DateTime.monday, hour: 9), activityName: 'Final'),
          createActivity(weekday(reference, DateTime.wednesday, hour: 9), activityName: 'FINAL'),
          createActivity(weekday(reference, DateTime.friday, hour: 9), activityName: 'final'),
        ];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.getLastRegularCourseDate(), isNull);
      });

      test('returns correct date when regular activities exist', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = createWeekActivities(monday);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        final lastDate = analyzer.getLastRegularCourseDate();
        expect(lastDate, isNotNull);
        expect(lastDate!.day, weekday(reference, DateTime.friday, hour: 9).day);
      });

      test('excludes Final activities (case-insensitive)', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = [
          createActivity(weekday(reference, DateTime.monday, hour: 9)),
          createActivity(weekday(reference, DateTime.wednesday, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, hour: 9)),
          createActivity(weekday(reference, DateTime.monday, week: 1, hour: 9), activityName: 'Final'),
          createActivity(weekday(reference, DateTime.wednesday, week: 1, hour: 9), activityName: 'FINAL'),
          createActivity(weekday(reference, DateTime.friday, week: 1, hour: 9), activityName: 'final'),
        ];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        final lastDate = analyzer.getLastRegularCourseDate();
        expect(lastDate, isNotNull);
        expect(lastDate!.day, weekday(reference, DateTime.friday, hour: 9).day);
      });

      test('returns the latest date among all regular activities', () {
        final monday = weekday(reference, DateTime.monday);
        final activities = [
          createActivity(weekday(reference, DateTime.monday, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 2, hour: 9)),
          createActivity(weekday(reference, DateTime.wednesday, week: 1, hour: 9)),
          createActivity(weekday(reference, DateTime.monday, week: 3, hour: 9), activityName: 'Final'),
        ];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        final lastDate = analyzer.getLastRegularCourseDate();
        expect(lastDate, isNotNull);
        expect(lastDate!.day, weekday(reference, DateTime.friday, week: 2, hour: 9).day);
      });
    });
  });
}
