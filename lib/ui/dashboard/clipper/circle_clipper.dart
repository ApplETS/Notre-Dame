// Package imports:
import 'package:material_ui/material_ui.dart';

class CircleClipper extends CustomClipper<Path> {
  static const double curveDepth = 40.0;

  @override
  Path getClip(Size size) {
    final sideY = size.height - curveDepth;

    return Path()
      ..lineTo(0, sideY)
      ..quadraticBezierTo(size.width / 2, size.height + curveDepth, size.width, sideY)
      // Top corners. Negative spacing to account for BouncingScrollPhysics on iOS
      ..lineTo(size.width, -2000)
      ..lineTo(0, -2000)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
