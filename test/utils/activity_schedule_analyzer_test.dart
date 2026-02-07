// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/utils/activity_schedule_analyzer.dart';

void main() {
  CourseActivity createActivity(DateTime start, {Duration duration = const Duration(hours: 2)}) {
    return CourseActivity(
      courseGroup: 'LOG430-01',
      courseName: 'Architecture logicielle',
      activityName: 'Cours',
      activityDescription: 'Cours magistral',
      activityLocation: ['A-1234'],
      startDateTime: start,
      endDateTime: start.add(duration),
    );
  }

  List<CourseActivity> createWeekActivities(DateTime monday) {
    return [
      createActivity(monday.add(const Duration(hours: 9))), // Monday
      createActivity(monday.add(const Duration(days: 1, hours: 9))), // Tuesday
      createActivity(monday.add(const Duration(days: 2, hours: 9))), // Wednesday
      createActivity(monday.add(const Duration(days: 3, hours: 9))), // Thursday
      createActivity(monday.add(const Duration(days: 4, hours: 9))), // Friday
    ];
  }

  group('ActivityScheduleAnalyzer -', () {
    group('getActivitiesInRange -', () {
      test('returns activities within range', () {
        final monday = DateTime(2024, 3, 11);
        final activities = createWeekActivities(monday);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        final result = analyzer.getActivitiesInRange(monday, monday.add(const Duration(days: 3)));

        expect(result.length, 3);
      });

      test('returns empty list when no activities in range', () {
        final monday = DateTime(2024, 3, 11);
        final activities = createWeekActivities(monday);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        final result = analyzer.getActivitiesInRange(
          monday.add(const Duration(days: 7)),
          monday.add(const Duration(days: 14)),
        );

        expect(result, isEmpty);
      });

      test('includes activities starting at range start, excludes at range end', () {
        final monday = DateTime(2024, 3, 11, 9);
        final activity = createActivity(monday);
        final analyzer = ScheduleAnalyzer(courseActivities: [activity], now: monday);

        // Activity at start is included
        expect(analyzer.getActivitiesInRange(monday, monday.add(const Duration(days: 1))), contains(activity));

        // Activity at end is excluded
        expect(analyzer.getActivitiesInRange(monday.subtract(const Duration(days: 1)), monday), isEmpty);
      });
    });

    group('getUniqueDays -', () {
      test('returns unique days sorted', () {
        final monday = DateTime(2024, 3, 11, 9);
        final activities = [
          createActivity(monday),
          createActivity(monday.add(const Duration(hours: 2))), // Same day
          createActivity(monday.add(const Duration(days: 1, hours: 9))),
        ];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        final result = analyzer.getUniqueDays(activities);

        expect(result.length, 2);
        // dateOnly returns UTC dates
        expect(result[0], DateTime.utc(2024, 3, 11));
        expect(result[1], DateTime.utc(2024, 3, 12));
      });

      test('returns empty list for empty activities', () {
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: DateTime(2024, 3, 11));

        expect(analyzer.getUniqueDays([]), isEmpty);
      });
    });

    group('hasNextWeekSchedule -', () {
      test('returns true when next week has activities', () {
        final monday = DateTime(2024, 3, 11);
        final nextMonday = monday.add(const Duration(days: 7));
        final activities = [...createWeekActivities(monday), ...createWeekActivities(nextMonday)];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.hasNextWeekSchedule, isTrue);
      });

      test('returns false when next week has no activities', () {
        final monday = DateTime(2024, 3, 11);
        final activities = createWeekActivities(monday);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.hasNextWeekSchedule, isFalse);
      });
    });

    group('isAfterLastCourseOfWeek -', () {
      test('returns true when after last course', () {
        final monday = DateTime(2024, 3, 11);
        final activities = createWeekActivities(monday);
        // Friday at 15:00 (after Friday 9:00 + 2h course)
        final now = monday.add(const Duration(days: 4, hours: 15));
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

        expect(analyzer.isAfterLastCourseOfWeek, isTrue);
      });

      test('returns false when before last course ends', () {
        final monday = DateTime(2024, 3, 11);
        final activities = createWeekActivities(monday);
        // Friday at 10:00 (during Friday 9:00-11:00 course)
        final now = monday.add(const Duration(days: 4, hours: 10));
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

        expect(analyzer.isAfterLastCourseOfWeek, isFalse);
      });

      test('returns false when no activities this week', () {
        final monday = DateTime(2024, 3, 11);
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: monday);

        expect(analyzer.isAfterLastCourseOfWeek, isFalse);
      });
    });

    group('isLastCourseDayOfWeek -', () {
      test('returns true on the last day with courses', () {
        final monday = DateTime(2024, 3, 11);
        final activities = createWeekActivities(monday);
        // Friday (the last course day)
        final now = monday.add(const Duration(days: 4, hours: 10));
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

        expect(analyzer.isLastCourseDayOfWeek, isTrue);
      });

      test('returns false on a day before the last course day', () {
        final monday = DateTime(2024, 3, 11);
        final activities = createWeekActivities(monday);
        // Thursday
        final now = monday.add(const Duration(days: 3, hours: 10));
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

        expect(analyzer.isLastCourseDayOfWeek, isFalse);
      });

      test('returns true when only one course day and its today', () {
        final monday = DateTime(2024, 3, 11);
        final activities = [createActivity(monday.add(const Duration(hours: 9)))];
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: monday.add(const Duration(hours: 10)),
        );

        expect(analyzer.isLastCourseDayOfWeek, isTrue);
      });
    });

    group('isNextWeekShorter -', () {
      test('returns true when next week has fewer than 5 course days', () {
        final monday = DateTime(2024, 3, 11);
        final nextMonday = monday.add(const Duration(days: 7));
        final activities = [
          ...createWeekActivities(monday),
          // Only 3 days next week
          createActivity(nextMonday.add(const Duration(hours: 9))),
          createActivity(nextMonday.add(const Duration(days: 1, hours: 9))),
          createActivity(nextMonday.add(const Duration(days: 2, hours: 9))),
        ];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.isNextWeekShorter, isTrue);
      });

      test('returns false when next week has 5 course days', () {
        final monday = DateTime(2024, 3, 11);
        final nextMonday = monday.add(const Duration(days: 7));
        final activities = [...createWeekActivities(monday), ...createWeekActivities(nextMonday)];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.isNextWeekShorter, isFalse);
      });

      test('returns true when next week has no activities', () {
        final monday = DateTime(2024, 3, 11);
        final activities = createWeekActivities(monday);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.isNextWeekShorter, isTrue);
      });
    });

    group('courseDaysThisWeek -', () {
      test('returns number of unique course days', () {
        final monday = DateTime(2024, 3, 11);
        final activities = createWeekActivities(monday);
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.courseDaysThisWeek, 5);
      });

      test('counts multiple activities on same day as one day', () {
        final monday = DateTime(2024, 3, 11);
        final activities = [
          createActivity(monday.add(const Duration(hours: 9))),
          createActivity(monday.add(const Duration(hours: 13))),
          createActivity(monday.add(const Duration(days: 1, hours: 9))),
        ];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: monday);

        expect(analyzer.courseDaysThisWeek, 2);
      });

      test('returns 0 when no activities this week', () {
        final monday = DateTime(2024, 3, 11);
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: monday);

        expect(analyzer.courseDaysThisWeek, 0);
      });
    });

    group('calculateUsualWeekendGapDays -', () {
      test('returns default when less than 2 activities', () {
        final analyzer = ScheduleAnalyzer(
          courseActivities: [createActivity(DateTime(2024, 3, 11, 9))],
          now: DateTime(2024, 3, 11),
        );

        expect(
          analyzer.calculateUsualWeekendGapDays(excludeStart: DateTime(2024, 3, 11), excludeEnd: DateTime(2024, 3, 18)),
          3,
        );
      });

      test('calculates median gap across weeks', () {
        final activities = [
          // Week 1: Thursday March 7
          createActivity(DateTime(2024, 3, 7, 9)),
          // Week 2: Monday March 11 (4 days gap: Fri, Sat, Sun, Mon)
          createActivity(DateTime(2024, 3, 11, 9)),
          // Week 2: Thursday March 14
          createActivity(DateTime(2024, 3, 14, 9)),
          // Week 3: Monday March 18 (4 days gap)
          createActivity(DateTime(2024, 3, 18, 9)),
        ];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: DateTime(2024, 3, 11));

        // Both cross-week gaps are 4 days (Thu to Mon)
        expect(
          analyzer.calculateUsualWeekendGapDays(excludeStart: DateTime(2024, 3, 25), excludeEnd: DateTime(2024, 4, 1)),
          4,
        );
      });

      test('excludes specified gap from calculation', () {
        final activities = [
          // Week 1: Thursday March 7
          createActivity(DateTime(2024, 3, 7, 9)),
          // Week 2: Monday March 11 (4 days gap)
          createActivity(DateTime(2024, 3, 11, 9)),
          // Week 2: Thursday March 14
          createActivity(DateTime(2024, 3, 14, 9)),
          // Week 3: Wednesday March 20 (6 days gap - long weekend)
          createActivity(DateTime(2024, 3, 20, 9)),
        ];
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: DateTime(2024, 3, 14));

        // Exclude the long weekend gap (March 14 to March 20)
        final result = analyzer.calculateUsualWeekendGapDays(
          excludeStart: DateTime(2024, 3, 14),
          excludeEnd: DateTime(2024, 3, 20),
        );

        // Should return 4 (the normal weekend gap), not be influenced by the 6-day gap
        expect(result, 4);
      });
    });

    group('isLongWeekendIncoming -', () {
      test('returns true when next gap is longer than usual', () {
        final activities = [
          // Week 1: Friday
          createActivity(DateTime(2024, 3, 8, 9)),
          // Week 2: Monday
          createActivity(DateTime(2024, 3, 11, 9)),
          // Week 2: Friday
          createActivity(DateTime(2024, 3, 15, 9)),
          // Week 3: Wednesday (long weekend - 5 day gap)
          createActivity(DateTime(2024, 3, 20, 9)),
        ];
        // Now is Thursday of week 2
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: DateTime(2024, 3, 14));

        expect(analyzer.isLongWeekendIncoming, isTrue);
      });

      test('returns false when gap is normal', () {
        final monday = DateTime(2024, 3, 11);
        final nextMonday = monday.add(const Duration(days: 7));
        final activities = [...createWeekActivities(monday), ...createWeekActivities(nextMonday)];
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: monday.add(const Duration(days: 4)), // Friday
        );

        expect(analyzer.isLongWeekendIncoming, isFalse);
      });

      test('returns false when no activities this week', () {
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: DateTime(2024, 3, 11));

        expect(analyzer.isLongWeekendIncoming, isFalse);
      });
    });

    group('isInsideLongWeekend -', () {
      test('returns true when gap to next activity is longer than usual', () {
        final activities = [
          // Week 1: Friday
          createActivity(DateTime(2024, 3, 8, 9)),
          // Week 2: Monday
          createActivity(DateTime(2024, 3, 11, 9)),
          // Week 2: Friday
          createActivity(DateTime(2024, 3, 15, 9)),
          // Week 3: Wednesday (long weekend)
          createActivity(DateTime(2024, 3, 20, 9)),
        ];
        // Now is Saturday of week 2 (inside the long weekend)
        final analyzer = ScheduleAnalyzer(courseActivities: activities, now: DateTime(2024, 3, 16, 12));

        expect(analyzer.isInsideLongWeekend, isTrue);
      });

      test('returns false when gap is normal', () {
        final monday = DateTime(2024, 3, 11);
        final nextMonday = monday.add(const Duration(days: 7));
        final activities = [...createWeekActivities(monday), ...createWeekActivities(nextMonday)];
        // Saturday (normal weekend)
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: monday.add(const Duration(days: 5, hours: 12)), // Saturday
        );

        expect(analyzer.isInsideLongWeekend, isFalse);
      });

      test('returns false when no activities', () {
        final analyzer = ScheduleAnalyzer(courseActivities: [], now: DateTime(2024, 3, 11));

        expect(analyzer.isInsideLongWeekend, isFalse);
      });

      test('returns false when still in an activity', () {
        final monday = DateTime(2024, 3, 11, 9);
        final activities = [createActivity(monday, duration: const Duration(hours: 3))];
        // During the activity
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: monday.add(const Duration(hours: 1)),
        );

        expect(analyzer.isInsideLongWeekend, isFalse);
      });

      test('returns false when no future activities', () {
        final monday = DateTime(2024, 3, 11, 9);
        final activities = [createActivity(monday)];
        // After the only activity
        final analyzer = ScheduleAnalyzer(
          courseActivities: activities,
          now: monday.add(const Duration(days: 1)),
        );

        expect(analyzer.isInsideLongWeekend, isFalse);
      });
    });
  });
}
