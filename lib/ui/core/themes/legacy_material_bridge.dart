// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
// Several dependencies (calendar_view, table_calendar, skeletonizer, ...) still use the legacy
// Material library, so the app has to expose a legacy theme to them.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy;

// Project imports:
import 'package:notredame/ui/core/themes/app_theme.dart';

/// Exposes the current `material_ui` theme and localizations to widgets of dependencies that
/// still use `package:flutter/material.dart`, and adds the calendar_view theme extensions.
class LegacyMaterialBridge extends StatelessWidget {
  final Widget child;

  const LegacyMaterialBridge({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      // Temporary migration utility: remove once all dependencies use package:material_ui.
      // ignore: deprecated_member_use
      MaterialUiCompatibilityBridge(
        child: Builder(
          builder: (context) {
            final legacyTheme = legacy.Theme.of(context);
            return legacy.Theme(
              data: legacyTheme.copyWith(
                extensions: [
                  ...legacyTheme.extensions.values,
                  ...AppTheme.calendarExtensions(Theme.of(context).brightness),
                ],
              ),
              child: child,
            );
          },
        ),
      );
}

/// Provides a transparent legacy `Material` ancestor to widgets of dependencies that still use
/// `package:flutter/material.dart` and need one (e.g. their `InkWell`s), since `material_ui`
/// widgets such as `Scaffold` or `Card` don't provide it.
class LegacyMaterialScope extends StatelessWidget {
  final Widget child;

  const LegacyMaterialScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) => legacy.Material(type: legacy.MaterialType.transparency, child: child);
}
