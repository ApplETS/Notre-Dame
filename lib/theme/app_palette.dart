import 'package:flutter/material.dart';

abstract class AppPalette {
  static const Color etsLightRed = Color(0xffef3e45);
  static const Color etsDarkRed = Color(0xffbf311a);
  static const Color appletsPurple = Color(0xff19375f);

  static const Color gradeFailureMin = Color(0xffd32f2f);
  static const Color gradeFailureMax = Color(0xffff7043);
  static const Color gradePassing = Color(0xfffff176);
  static const Color gradeGoodMin = Color(0xffaed581);
  static const Color gradeGoodMax = Color(0xff43a047);

  static const grey = _GreyColors();

  static const List<Color> schedule = [
    Color(0xfff1c40f),
    Color(0xffe67e22),
    Color(0xffe91e63),
    Color(0xff16a085),
    Color(0xff2ecc71),
    Color(0xff3498db),
    Color(0xff9b59b6),
    Color(0xff34495e),
    Color(0xffe67e22),
    Color(0xffe74c3c),
  ];

  static const List<Color> tags = [
    Color(0xfff39c12),
    Color(0xffef476f),
    Color(0xffd35400),
    Color(0xff16a085),
    Color.fromARGB(255, 46, 151, 204),
    Color(0xff8e44ad),
    Color.fromARGB(255, 12, 168, 77),
    Color.fromARGB(255, 161, 185, 41),
  ];
}

class _GreyColors {
  const _GreyColors();

  final Color lightGrey = const Color(0xff807f83);
  final Color darkGrey = const Color(0xff636467);
  final Color black = const Color(0xff2e2a25);
}