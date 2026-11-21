// Package imports:
import 'package:material_ui/material_ui.dart';

/// Banner shape used by the landscape dashboard: full height on the left, sweeping
/// up to the top edge on the right with a curve.
class SwooshClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Negative spacing to account for BouncingScrollPhysics on iOS
    path.moveTo(0, -2000);
    path.lineTo(size.width, -2000);
    path.lineTo(size.width, 0);

    // Curve from the top right corner down to the bottom left corner
    path.cubicTo(size.width * 0.95, size.height * 0.75, size.width * 0.6, size.height * 0.88, 0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
