// Flutter imports:
import 'package:flutter/widgets.dart';

class AdaptiveAlwaysScrollablePhysics extends ScrollPhysics {
  const AdaptiveAlwaysScrollablePhysics({super.parent});

  @override
  AdaptiveAlwaysScrollablePhysics applyTo(ScrollPhysics? ancestor) =>
      AdaptiveAlwaysScrollablePhysics(parent: buildParent(ancestor));

  bool _overflows(ScrollMetrics m) => m.maxScrollExtent > m.minScrollExtent;

  ScrollPhysics _delegate(ScrollMetrics m) {
    return _overflows(m)
        ? const AlwaysScrollableScrollPhysics().applyTo(parent)
        : const AlwaysScrollableScrollPhysics().applyTo(const ClampingScrollPhysics().applyTo(parent));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => _delegate(position).shouldAcceptUserOffset(position);

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) =>
      _delegate(position).applyPhysicsToUserOffset(position, offset);

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) =>
      _delegate(position).applyBoundaryConditions(position, value);

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) =>
      _delegate(position).createBallisticSimulation(position, velocity);
}
