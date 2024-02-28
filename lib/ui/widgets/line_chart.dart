// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:notredame/core/managers/grade_graph_repository.dart';
import 'package:notredame/core/models/grade_graph_entry.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class LineChartGradeGraph extends StatefulWidget {
  final String _courseAcronym;
  final String _group;
  final String _session;

  const LineChartGradeGraph(this._courseAcronym, this._group, this._session);

  @override
  State<LineChartGradeGraph> createState() => _LineChartGradeGraphState();
}

class _LineChartGradeGraphState extends State<LineChartGradeGraph> {
  List<Color> gradientColors = [
    AppTheme.etsLightRed,
    AppTheme.etsDarkRed,
  ];

  double maxX = -1;
  double maxY = 100;
  double verticalInterval;
  DateTime earliestGradeDate;

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
            child: FutureBuilder<List<GradeGraphEntry>>(
                future: _gradeGraphRepository.getGradesForCourse(
                    widget._courseAcronym, widget._group, widget._session),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasData) {
                      return LineChart(
                        getLinechartData(snapshot.data),
                        swapAnimationDuration:
                            const Duration(milliseconds: 250),
                      );
                    } else {
                      return const Center(child: Text('No data'));
                    }
                  }
                }),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    if (value % verticalInterval != 0) {
      return Container();
    }

    final DateFormat dateFormat = DateFormat('MMM d');
    final Duration durationInDays = Duration(days: value.toInt());
    final DateTime date = earliestGradeDate.add(durationInDays);
    final Widget titleText = Text(dateFormat.format(date), style: style);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 50:
        text = '50%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData getLinechartData(List<GradeGraphEntry> grades) {
    if (grades.isNotEmpty) {
      earliestGradeDate = grades.first.timestamp;
      maxX = earliestGradeDate.getDayDifference(DateTime.now()).toDouble();
    }

    final List<FlSpot> spots = [];
    for (final grade in grades) {
      final FlSpot newSpot = FlSpot(
          grade.timestamp.getDayDifference(earliestGradeDate).toDouble(),
          grade.summary.currentMarkInPercent);
      spots.add(newSpot);
    }

    if (spots.last.x != maxX) {
      // Adding a spot to fill the graph up to current date.
      final FlSpot lastSpot =
          FlSpot(maxX, grades.last.summary.currentMarkInPercent);
      spots.add(lastSpot);
    }

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
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 25,
            getTitlesWidget: leftTitleWidgets,
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
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppTheme.etsLightRed,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.etsLightRed.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
