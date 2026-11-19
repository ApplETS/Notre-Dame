// Project imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:notredame/ui/core/ui/navigation_menu/navigation_menu_button.dart';

class NavigationMenuCallback {
  final int index;
  final GlobalKey<NavigationMenuButtonState> newKey;
  final GlobalKey<NavigationMenuButtonState> oldKey;

  NavigationMenuCallback(this.index, this.newKey, this.oldKey);
}
