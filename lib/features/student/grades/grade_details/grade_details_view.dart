// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/student/grades/grade_details/grades_details_viewmodel.dart';
import 'package:notredame/features/student/grades/grade_details/widget/class_info.dart';
import 'package:notredame/features/student/grades/grade_details/widget/grade_evaluations.dart';
import 'package:notredame/utils/app_theme.dart';

class GradesDetailsView extends StatefulWidget {
  final Course course;

  const GradesDetailsView({required this.course});

  @override
  _GradesDetailsViewState createState() => _GradesDetailsViewState();
}

class _GradesDetailsViewState extends State<GradesDetailsView>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _completed = true;
        });
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      GradesDetailsViewModel.startDiscovery(context);
    });
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<GradesDetailsViewModel>.reactive(
        viewModelBuilder: () => GradesDetailsViewModel(
            course: widget.course, intl: AppIntl.of(context)!),
        builder: (context, model, child) => BaseScaffold(
          safeArea: false,
          showBottomBar: false,
          body: Material(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxScrolled) => [
                SliverAppBar(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? AppTheme.etsLightRed
                          : BottomAppBarTheme.of(context).color,
                  pinned: true,
                  onStretchTrigger: () {
                    return Future<void>.value();
                  },
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Hero(
                    tag:
                        'course_acronym_${model.course.acronym}_${model.course.session}',
                    child: Text(
                      model.course.acronym,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppTheme.etsLightRed
                            : AppTheme.darkTheme().cardColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ClassInfo(info: model.course.title),
                              if (model.course.teacherName != null)
                                ClassInfo(
                                    info: AppIntl.of(context)!.grades_teacher(
                                        model.course.teacherName!)),
                              ClassInfo(
                                  info: AppIntl.of(context)!
                                      .grades_group_number(model.course.group)),
                              ClassInfo(
                                  info: AppIntl.of(context)!.credits_number(
                                      model.course.numberOfCredits)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GradeEvaluations(
                    model: model,
                    completed: _completed,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
