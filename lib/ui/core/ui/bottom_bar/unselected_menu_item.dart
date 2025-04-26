import 'package:flutter/material.dart';

import 'package:notredame/ui/core/ui/bottom_bar/button_properties.dart';

class UnselectedMenuItem extends StatefulWidget {
  final ButtonProperties properties;

  const UnselectedMenuItem({super.key, required this.properties});

  @override
  State<UnselectedMenuItem> createState() => _UnselectedMenuItemState();
}

class _UnselectedMenuItemState extends State<UnselectedMenuItem> {

  @override
  Widget build(BuildContext context) => Expanded(
        child: IconButton(
          tooltip: widget.properties.label,
          icon: Icon(widget.properties.icon),
          onPressed: () {
            widget.properties.onPressed();
          },
        ),
      );
}
