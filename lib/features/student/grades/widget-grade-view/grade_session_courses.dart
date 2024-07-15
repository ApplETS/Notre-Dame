// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/student/grades/widgets/grade_button.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/locator.dart';

class GradeSessionCourses extends StatelessWidget {
  final int index;
  final String sessionName;
  final List<Course> courses;
  final List<String> sessionOrder;

  GradeSessionCourses({
    required this.index,
    required this.sessionName,
    required this.courses,
    required this.sessionOrder,
  });

  final NavigationService _navigationService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                sessionName,
                style: const TextStyle(
                  fontSize: 25,
                  color: AppTheme.etsLightRed,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.today, color: AppTheme.etsDarkGrey),
                onPressed: () => _navigationService.pushNamed(
                    RouterPaths.defaultSchedule,
                    arguments: sessionOrder[index]),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Wrap(
            children: courses
                .map((course) => GradeButton(course, showDiscovery: index == 0))
                .toList(),
          ),
        ],
      ),
    );
  }
}
