// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:ets_api_clients/models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:notredame/core/managers/grade_graph_repository.dart';
import 'package:notredame/core/models/grade_progression_entry.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';

/// A line chart that displays the grade progression for a course.
class LineChartGradeGraph extends StatefulWidget {
  final String _courseAcronym;
  final String _group;
  final Session _session;

  const LineChartGradeGraph(this._courseAcronym, this._group, this._session);

  @override
  State<LineChartGradeGraph> createState() => _LineChartGradeGraphState();
}

/// The state of the LineChartGradeGraph.
class _LineChartGradeGraphState extends State<LineChartGradeGraph> {
  List<Color> gradientColors = [
    AppTheme.etsLightRed,
    AppTheme.etsDarkRed,
  ];

  double maxX = -1;
  double maxY = 100;
  double verticalInterval = 0;
  DateTime earliestGradeDate = DateTime.now();

  final GradeGraphRepository _gradeGraphRepository =
      locator<GradeGraphRepository>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: FutureBuilder<List<GradeProgressionEntry>>(
                future: _gradeGraphRepository.getGradesForCourse(
                    widget._courseAcronym,
                    widget._group,
                    widget._session.shortName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.data!.length > 2) {
                      return LineChart(
                        getLinechartData(snapshot.data!),
                        swapAnimationDuration:
                            const Duration(milliseconds: 250),
                      );
                    } else {
                      return Center(
                          child:
                              Text(AppIntl.of(context)!.grades_no_graph_data));
                    }
                  }
                }),
          ),
        ),
      ],
    );
  }

  /// Returns the widget to display the X axis titles.
  Widget xAxisTitleWidgets(double value, TitleMeta meta) {
    // Only display the date if it is a multiple of the vertical interval.
    if (value % verticalInterval != 0) {
      return Container();
    }

    final DateFormat dateFormat =
        DateFormat('MMM d', AppIntl.of(context)!.localeName);
    final Duration durationInDays = Duration(days: value.toInt());
    final DateTime date = earliestGradeDate.add(durationInDays);

    final Widget titleText = Text(dateFormat.format(date),
        style: Theme.of(context).textTheme.bodyLarge);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: titleText,
    );
  }

  /// Returns the widget to display the Y axis titles.
  /// The [value] is the value of the Y axis.
  Widget yAxisTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
      case 50:
        text = '50%';
      case 100:
        text = '100%';
      default:
        return Container();
    }

    return Text(text,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.left);
  }

  /// Returns the data for the line chart using the specified [grades] list.

  LineChartData getLinechartData(List<GradeProgressionEntry> grades) {
    earliestGradeDate = grades.first.timestamp!;

    final DateTime theoreticalSessionEnd = widget._session.endDate.add(
        const Duration(
            days: 5 * 7)); // Add 5 weeks as grace period for grade submission.
    final DateTime latestGradeDate = grades.last.timestamp!;

    DateTime maxXDate;
    if (theoreticalSessionEnd.isAfter(DateTime.now())) {
      maxXDate = DateTime.now();
    } else {
      // Very small chance that the latest grade of the course hasn't been submitted yet.
      maxXDate = latestGradeDate;
    }

    maxX = earliestGradeDate.getDayDifference(maxXDate).toDouble();

    verticalInterval = maxX / 4;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: maxY / 10,
        verticalInterval: verticalInterval,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppTheme.etsLightGrey,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: AppTheme.etsLightGrey,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: verticalInterval,
            getTitlesWidget: xAxisTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 25,
            getTitlesWidget: yAxisTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: AppTheme.etsDarkGrey),
      ),
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: maxY,
      lineBarsData: getLineBarsData(grades),
    );
  }

  Future<List<GradeProgressionEntry>> getGradesForCourseMock(
      int nbOfEntries) async {
    final List<GradeProgressionEntry> result = <GradeProgressionEntry>[];
    final Random gen = Random();
    DateTime date = widget._session.endDate.add(const Duration(days: 5 * 7));

    for (int i = 0; i < nbOfEntries; i++) {
      final CourseSummary summary = CourseSummary(
          currentMarkInPercent: (gen.nextDouble() * 100).floorToDouble(),
          markOutOf: 100,
          evaluations: <CourseEvaluation>[]);

      final GradeProgressionEntry entry = GradeProgressionEntry.withTimeStamp(
          timestamp: date,
          acronym: "MAT350",
          group: "02",
          session: "H2024",
          summary: summary);
      result.add(entry);

      date = date.subtract(Duration(days: gen.nextInt(50)));
    }

    result.sort((a, b) => _gradeGraphRepository.gradeSortAlgorithm(a, b));

    return result;
  }

  /// Returns the data for the line bars using the specified [grades] list.
  List<LineChartBarData> getLineBarsData(List<GradeProgressionEntry> grades) {
    final List<FlSpot> spots = getSpots(grades);
    final double latestGradeXValue =
        earliestGradeDate.getDayDifference(grades.last.timestamp!).toDouble();

    return [
      LineChartBarData(
        spots: spots,
        isCurved: false,
        color: AppTheme.etsLightRed,
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          // Only show the dot if the last spot isn't the latest grade's date (meaning last spot is today).
          checkToShowDot: (spot, barData) =>
              !(spot.x == maxX && latestGradeXValue != maxX),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: AppTheme.etsLightRed.withOpacity(0.3),
        ),
      ),
    ];
  }

  /// Returns the spots for the line chart using the specified [grades] list.
  List<FlSpot> getSpots(List<GradeProgressionEntry> grades) {
    final List<FlSpot> spots = [];
    for (final grade in grades) {
      final FlSpot newSpot = FlSpot(
          grade.timestamp!.getDayDifference(earliestGradeDate).toDouble(),
          grade.summary!.currentMarkInPercent);
      spots.add(newSpot);
    }

    if (spots.last.x < maxX) {
      // Adding a spot to fill the graph up to current date.
      final FlSpot lastSpot =
          FlSpot(maxX, grades.last.summary!.currentMarkInPercent);
      spots.add(lastSpot);
    }

    return spots;
  }
}
