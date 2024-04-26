// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/ui/utils/app_theme.dart';

class StudentProgram extends StatefulWidget {
  final Program _program;
  const StudentProgram(this._program);

  @override
  State<StudentProgram> createState() => _StudentProgramState();
}

class _StudentProgramState extends State<StudentProgram>
    with TickerProviderStateMixin<StudentProgram> {
  bool showProgramDetails = false;
  late AnimationController controller;
  late Animation<double> rotateAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this,
        duration: const Duration(
          milliseconds: 200,
        ),
        value: 1.0);

    rotateAnimation = Tween(begin: pi, end: 0.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;

    final List<String> dataTitles = [
      AppIntl.of(context)!.profile_code_program,
      AppIntl.of(context)!.profile_average_program,
      AppIntl.of(context)!.profile_number_accumulated_credits_program,
      AppIntl.of(context)!.profile_number_registered_credits_program,
      AppIntl.of(context)!.profile_number_completed_courses_program,
      AppIntl.of(context)!.profile_number_failed_courses_program,
      AppIntl.of(context)!.profile_number_equivalent_courses_program,
      AppIntl.of(context)!.profile_status_program
    ];

    final List<String> dataFetched = [
      widget._program.code,
      widget._program.average,
      widget._program.accumulatedCredits,
      widget._program.registeredCredits,
      widget._program.completedCourses,
      widget._program.failedCourses,
      widget._program.equivalentCourses,
      widget._program.status
    ];

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        unselectedWidgetColor: Colors.red,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          onSecondary: Colors.red,
        ),
      ),
      child: ExpansionTile(
        onExpansionChanged: (value) {
          setState(() {
            showProgramDetails = !showProgramDetails;

            if (showProgramDetails) {
              controller.reverse(from: pi);
            } else {
              controller.forward(from: 0.0);
            }
          });
        },
        title: Text(
          widget._program.name,
          style: TextStyle(
            color: isLightMode ? Colors.black : Colors.white,
          ),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: AnimatedBuilder(
            animation: rotateAnimation,
            builder: (BuildContext context, Widget? child) {
              return Transform.rotate(
                angle: rotateAnimation.value,
                child: const Icon(
                  Icons.keyboard_arrow_down_sharp,
                  color: AppTheme.etsLightRed,
                ),
              );
            },
            child: const Icon(
              Icons.keyboard_arrow_down_sharp,
              color: AppTheme.etsLightRed,
            ),
          ),
        ),
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List<Widget>.generate(dataTitles.length, (index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(dataTitles[index]),
                    Text(dataFetched[index]),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
