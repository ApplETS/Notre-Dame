import 'package:flutter/cupertino.dart';

class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Début du tracé en bas à gauche du conteneur à 60 pixels du bas
    path.lineTo(0, size.height - 60);

    // Création d'une courbe de Bézier quadratique vers le coin inférieur droit
    // avec un point de contrôle situé au centre inférieur (width / 2, height)
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);

    // Ligne jusqu'au coin supérieur droit
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  // Indique si le clip doit être recalculé
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
