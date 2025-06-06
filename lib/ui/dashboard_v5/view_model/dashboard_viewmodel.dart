import 'package:flutter/material.dart';

class DashboardViewModelV5 extends ChangeNotifier {
  late AnimationController controller;
  late Animation<double> heightAnimation;
  late Animation<double> opacityAnimation;

  void init(TickerProvider ticker) {
    controller = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 1500),
    );

    // Animation de la grandeur du cercle
    // grandit de (0) jusqu'à la fin (330)
    heightAnimation = Tween<double>(begin: 0, end: 330).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.ease,
      ),
    );

    // Animation pour l'opacity du cercle
    // de transparent (0.0) jusqu'à opaque (1.0)
    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
