// Flutter imports:
import 'package:flutter/cupertino.dart';

class CircleClipper extends CustomClipper<Path> {
  /// Gets the path of the circle
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start of path at bottom left of container 60 pixels from bottom
    path.lineTo(0, size.height - 60);

    // Creating a quadratic Bezier curve to the lower right corner
    // With a control point located at the bottom center (width / 2, height)
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);

    // Line to the upper right corner
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  // Indicates whether the clip should be calculated
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
