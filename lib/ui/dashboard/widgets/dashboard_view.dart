// Package imports:
import 'package:material_ui/material_ui.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/dashboard/scroll_physics/adaptative_always_scrollable_physics.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/layouts/dashboard_phone_horizontal_layout.dart';
import 'package:notredame/ui/dashboard/widgets/layouts/dashboard_phone_vertical_layout.dart';
import 'package:notredame/ui/dashboard/widgets/layouts/dashboard_tablet_horizontal_layout.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with SingleTickerProviderStateMixin {
  /// Shortest side from which the device is considered a tablet.
  static const double _tabletShortestSide = 600.0;

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
            onRefresh: model.refresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AdaptiveAlwaysScrollablePhysics(),
                  child: _layout(context, model, constraints.maxHeight),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _layout(BuildContext context, DashboardViewModel model, double viewportHeight) {
    if (MediaQuery.orientationOf(context) == Orientation.portrait) {
      return DashboardPhoneVerticalLayout(model: model, viewportHeight: viewportHeight);
    }
    if (MediaQuery.sizeOf(context).shortestSide >= _tabletShortestSide) {
      return DashboardTabletHorizontalLayout(model: model, viewportHeight: viewportHeight);
    }
    return DashboardPhoneHorizontalLayout(model: model, viewportHeight: viewportHeight);
  }
}
