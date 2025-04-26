import 'package:flutter/cupertino.dart';

class ButtonProperties {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const ButtonProperties(this.label, this.icon, this.onPressed);
}
