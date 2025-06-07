import 'package:flutter/material.dart';

import '../../../data/repositories/user_repository.dart';
import '../../../locator.dart';

class DashboardViewModelV5 extends ChangeNotifier {
  late final UserRepository _userRepository = locator<UserRepository>();

  late AnimationController controller;
  late Animation<double> heightAnimation;
  late Animation<double> opacityAnimation;

  /// Get the list of programs for the student
  Future<void> fetchUserInfo() async {
    await _userRepository.getInfo();
    notifyListeners();
  }

  /// Get full name of the user
  String getFullName() {
    final info = _userRepository.info;
    if (info == null) return '';
    return '${info.firstName} ${info.lastName}'.trim();
  }

  /// Animation controller for the circle
  void init(TickerProvider ticker) {
    controller = AnimationController(
      vsync: ticker,
      duration: const Duration(milliseconds: 1500),
    );

    // Animation of the circle's height
    // Grows from (0) to the end (330)
    heightAnimation = Tween<double>(begin: 0, end: 330).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.ease,
      ),
    );

    // Animation for the circle's opacity
    // From transparent (0.0) to opaque (1.0)
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
