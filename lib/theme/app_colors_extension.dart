import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  AppColorsExtension({
    required this.appBar,
    required this.navBar
  });

  final Color appBar;
  final Color navBar;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? appBar,
    Color? navBar,
  }) {
    return AppColorsExtension(
      appBar: appBar ?? this.appBar,
      navBar: navBar ?? this.navBar
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
      covariant ThemeExtension<AppColorsExtension>? other,
      double t,
      ) {
    if (other is! AppColorsExtension) {
      return this;
    }

    return AppColorsExtension(
      appBar: Color.lerp(appBar, other.appBar, t)!,
      navBar: Color.lerp(navBar, other.navBar, t)!,
    );
  }
}

// /// Optional. If you also want to assign colors in the `ColorScheme`.
// extension ColorSchemeBuilder on AppColorsExtension {
//   ColorScheme toColorScheme(Brightness brightness) {
//     return ColorScheme(
//       brightness: brightness,
//       primary: primary,
//       onPrimary: onPrimary,
//       secondary: secondary,
//       onSecondary: onSecondary,
//       error: error,
//       onError: onError,
//       background: background,
//       onBackground: onBackground,
//       surface: surface,
//     );
//   }
// }