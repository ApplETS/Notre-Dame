// Dart imports:
import 'dart:math';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// Projet imports:
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/l10n/app_localizations.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final TransformationController _transformationController = TransformationController();
  bool _shouldDisplayLegend = true;

  @override
  Widget build(BuildContext context) => BaseScaffold(
    safeArea: false,
    appBar: AppBar(title: Text(AppIntl.of(context)!.more_map)),
    showBottomBar: false,
    body: LayoutBuilder(
      builder: (context, constraints) {
        double height = constraints.maxHeight;
        double width = constraints.maxWidth;

        const minAspectRatio = 0.5;
        const maxAspectRatio = 2.7;

        bool vertical = height > width;

        double aspectRatio = clampDouble(width / height, minAspectRatio, maxAspectRatio);
        double scale = clampDouble(2.5 - (vertical ? 2.4 : 0.9) * (1 - aspectRatio).abs(), 1.0, double.infinity);

        double mapHeight = min(height, height / minAspectRatio);
        double mapWidth = min(width, maxAspectRatio * height);

        return Stack(
          alignment: vertical ? Alignment.bottomCenter : Alignment.centerRight,
          children: [
            InteractiveViewer(
              minScale: 1.0,
              maxScale: 3.0,
              transformationController: _transformationController,
              onInteractionUpdate: (details) {
                bool shouldDisplayLegendUpdate = _transformationController.value.getMaxScaleOnAxis() == 1;
                if (_shouldDisplayLegend != shouldDisplayLegendUpdate) {
                  setState(() => _shouldDisplayLegend = shouldDisplayLegendUpdate);
                }
              },
              child: Transform.scale(
                scale: scale,
                alignment: AlignmentGeometry.xy(vertical ? 0 : 1.0, vertical ? 0.3 : 0),
                child: SvgPicture.asset(
                  "assets/images/map_${context.theme.brightness.name}.svg",
                  fit: BoxFit.cover,
                  height: vertical ? mapHeight : null,
                  width: vertical ? null : mapWidth,
                ),
              ),
            ),
            _legend(vertical, context),
          ],
        );
      },
    ),
  );

  Padding _legend(bool vertical, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: vertical ? 24.0 : 0.0, right: vertical ? 0.0 : 24.0),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        offset: _shouldDisplayLegend
            ? Offset.zero
            : vertical
            ? const Offset(0, 1)
            : const Offset(1, 0),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _shouldDisplayLegend ? 1 : 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: context.theme.appColors.mapLegend.withAlpha(180),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IntrinsicWidth(
              child: Flex(
                direction: vertical ? Axis.horizontal : Axis.vertical,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 24.0,
                children: [
                  Row(
                    spacing: 8.0,
                    children: [
                      SvgPicture.asset("assets/images/parking.svg", height: 32.0),
                      Text(
                        AppIntl.of(context)!.campus_map_legend_parking,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 8.0,
                    children: [
                      SvgPicture.asset("assets/images/bixi.svg", height: 32),
                      Text(
                        AppIntl.of(context)!.campus_map_legend_bixi,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
