// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';

// Project imports:
import 'package:notredame/features/welcome/discovery/discovery_components.dart';
import 'package:notredame/features/welcome/discovery/models/discovery_ids.dart';
import 'package:notredame/utils/app_theme.dart';

DescribedFeatureOverlay studentDiscoveryFeatureDescriptionWidget(
    BuildContext context, List<String> tabs, int index) {
  final discovery = getDiscoveryByFeatureId(context,
      DiscoveryGroupIds.pageStudent, DiscoveryIds.detailsStudentProfile);

  return DescribedFeatureOverlay(
    overflowMode: OverflowMode.wrapBackground,
    contentLocation: ContentLocation.below,
    featureId: discovery.featureId,
    title: Text(discovery.title, textAlign: TextAlign.justify),
    description: discovery.details,
    backgroundColor: AppTheme.appletsDarkPurple,
    tapTarget: Tab(
      child: Text(
        tabs[index],
        style: (Theme.of(context).brightness == Brightness.dark)
            ? const TextStyle(color: Colors.black)
            : null,
      ),
    ),
    pulseDuration: const Duration(seconds: 5),
    child: Tab(
      text: tabs[index],
    ),
  );
}
