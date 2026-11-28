// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';

/// Animated colored shape displayed behind the dashboard message.
class DashboardBanner extends StatelessWidget {
  final DashboardViewModel model;
  final CustomClipper<Path> clipper;

  /// Height of the banner once the animation is completed.
  final double height;

  const DashboardBanner({super.key, required this.model, required this.clipper, required this.height});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model.heightAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: model.opacityAnimation.value,
          child: PhysicalShape(
            clipper: clipper,
            elevation: 4.0,
            color: model.remoteConfigService.dashboardMessageActive
                ? model.broadcastMessage!.color
                : AppPalette.etsLightRed,
            child: SizedBox(height: height * model.heightAnimation.value, width: double.infinity),
          ),
        );
      },
    );
  }
}
