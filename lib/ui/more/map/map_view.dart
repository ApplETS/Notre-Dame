// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';

import '../../../l10n/app_localizations.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  Widget build(BuildContext context) => BaseScaffold(
    safeArea: false,
    appBar: AppBar(title: Text("Plan du campus")),
    showBottomBar: false,
    body: LayoutBuilder(
      builder: (context, constraints) {
        double height = constraints.maxHeight;
        double width = constraints.maxWidth;

        const maxHeightToWidthRatio = 1.12;
        const maxWidthToHeightRatio = 0.9;

        double mapHeight = min(height, maxHeightToWidthRatio * width);
        double mapWidth = min(width, maxWidthToHeightRatio * height);

        bool vertical = height > width;

        return Flex(
          direction: vertical ? Axis.vertical : Axis.horizontal,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: SvgPicture.asset(
                "assets/images/map_dark.svg",
                fit: BoxFit.cover,
                height: vertical ? mapHeight : null,
                width: vertical ? null : mapWidth + 120,
              ),
            ),
            Expanded(child: legend()),
          ],
        );
      },
    ),
  );

  Widget legend() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text("Légende"),
      Container(color: Colors.red),
    ],
  );
}
