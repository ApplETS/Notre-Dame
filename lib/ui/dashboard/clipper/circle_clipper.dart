// Package imports:
import 'package:material_ui/material_ui.dart';

class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start of path at bottom left of container 60 pixels from bottom
    path.lineTo(0, size.height - 60);

    // Creating a quadratic curve to the lower right corner
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);

    // Top corners. Negative spacing to account for BouncingScrollPhysics on iOS
    path.lineTo(size.width, -2000);
    path.lineTo(0, -2000);

    path.close();

    return path;
  }

  // Indicates whether the clip should be calculated
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
