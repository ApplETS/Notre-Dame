// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

class Program {
  final String name;
  final String code;
  final String average;
  final String accumulatedCredits;
  final String registeredCredits;
  final String completedCourses;
  final String failedCourses;
  final String equivalentCourses;
  final String status;

  Program(
      {@required this.name,
      @required this.code,
      @required this.average,
      @required this.accumulatedCredits,
      @required this.registeredCredits,
      @required this.completedCourses,
      @required this.failedCourses,
      @required this.equivalentCourses,
      @required this.status});
}
