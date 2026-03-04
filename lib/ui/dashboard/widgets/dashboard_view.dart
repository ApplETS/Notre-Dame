// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/dashboard/clipper/circle_clipper.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/layouts/dashboard_phone_layout.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    DashboardViewModel.launchInAppReview();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
      viewModelBuilder: () {
        final viewModel = DashboardViewModel(intl: AppIntl.of(context)!);
        viewModel.init(this);
        return viewModel;
      },
      builder: (context, model, child) {
        return BaseScaffold(
          body: RefreshIndicator(
            onRefresh: model.futureToRun,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Stack(
                    children: [
                      _redCircle(model),
                      DashboardPhoneLayout(model: model, viewportHeight: constraints.maxHeight),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Animated circle widget
  Widget _redCircle(DashboardViewModel model) {
    return AnimatedBuilder(
      animation: model.heightAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: model.opacityAnimation.value,
          child: PhysicalShape(
            clipper: CircleClipper(),
            elevation: 4.0,
            color: AppPalette.etsLightRed,
            child: SizedBox(height: model.heightAnimation.value, width: double.infinity),
          ),
        );
      },
    );
  }
}
