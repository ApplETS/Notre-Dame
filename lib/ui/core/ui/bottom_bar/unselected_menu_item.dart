import 'package:flutter/material.dart';

import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/locator.dart';

class UnselectedMenuItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final String route;

  const UnselectedMenuItem(
      {super.key,
        required this.label,
        required this.icon,
        required this.route
      });

  @override
  State<UnselectedMenuItem> createState() => _UnselectedMenuItemState();
}

class _UnselectedMenuItemState extends State<UnselectedMenuItem> {
  final NavigationService _navigationService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) => Expanded(
      child: IconButton(
        tooltip: widget.label,
        icon: Icon(widget.icon),
        onPressed: () {
          _navigationService.pushNamedAndRemoveDuplicates(widget.route);
        },
      ),
    );
}
