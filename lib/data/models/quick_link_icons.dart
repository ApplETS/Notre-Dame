// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';

/// Icons that can be referenced by name (`"icon": "<name>"`) in the `quicklinks_values` Remote Config.
///
/// Keys are the exact constant names of [FontAwesomeIcons] (e.g. `addressBook`, `solidHandshake`),
/// so the library stays the source of truth for the names.
///
/// The list is explicit on purpose: Flutter has no reflection to iterate over [FontAwesomeIcons], and a map
/// containing every icon would keep all Font Awesome glyphs in the app (no icon tree shaking).
/// To make a new icon available, add `'name': FontAwesomeIcons.name` here (requires an app release).
const Map<String, IconData> quickLinkIcons = {
  'addressBook': FontAwesomeIcons.addressBook,
  'addressCard': FontAwesomeIcons.addressCard,
  'book': FontAwesomeIcons.book,
  'bookOpen': FontAwesomeIcons.bookOpen,
  'briefcase': FontAwesomeIcons.briefcase,
  'buildingColumns': FontAwesomeIcons.buildingColumns,
  'bus': FontAwesomeIcons.bus,
  'calendar': FontAwesomeIcons.calendar,
  'calendarDays': FontAwesomeIcons.calendarDays,
  'circleInfo': FontAwesomeIcons.circleInfo,
  'circleQuestion': FontAwesomeIcons.circleQuestion,
  'comments': FontAwesomeIcons.comments,
  'envelope': FontAwesomeIcons.envelope,
  'flask': FontAwesomeIcons.flask,
  'globe': FontAwesomeIcons.globe,
  'graduationCap': FontAwesomeIcons.graduationCap,
  'house': FontAwesomeIcons.house,
  'laptop': FontAwesomeIcons.laptop,
  'link': FontAwesomeIcons.link,
  'mapLocationDot': FontAwesomeIcons.mapLocationDot,
  'newspaper': FontAwesomeIcons.newspaper,
  'peopleRoof': FontAwesomeIcons.peopleRoof,
  'phone': FontAwesomeIcons.phone,
  'print': FontAwesomeIcons.print,
  'sackDollar': FontAwesomeIcons.sackDollar,
  'solidHandshake': FontAwesomeIcons.solidHandshake,
  'userGraduate': FontAwesomeIcons.userGraduate,
  'users': FontAwesomeIcons.users,
  'userTie': FontAwesomeIcons.userTie,
  'utensils': FontAwesomeIcons.utensils,
};

/// Icon displayed when a link has no usable icon/svg (unknown icon name, missing or broken svg).
Widget quickLinkPlaceholderIcon() =>
    const FittedBox(child: FaIcon(FontAwesomeIcons.link, color: AppPalette.etsLightRed));

/// Build the image of a quick link: library icon first, then svg, then the placeholder.
Widget buildQuickLinkImage({String? icon, String? svg}) {
  final iconData = icon != null ? quickLinkIcons[icon] : null;
  if (iconData != null) {
    return FittedBox(child: FaIcon(iconData, color: AppPalette.etsLightRed));
  }

  if (svg != null) {
    try {
      return SvgPicture.string(
        validateQuickLinkSvg(svg),
        // The SVG markup itself is parsed when rendered, so a malformed SVG is handled here, not by the catch.
        errorBuilder: (context, error, stackTrace) => quickLinkPlaceholderIcon(),
      );
    } on FormatException {
      return quickLinkPlaceholderIcon();
    }
  }

  return quickLinkPlaceholderIcon();
}

/// Return the trimmed SVG markup of [svg].
///
/// Throws a [FormatException] if [svg] does not contain an `<svg>` element.
String validateQuickLinkSvg(String svg) {
  final value = svg.trim();
  if (!value.contains('<svg')) {
    throw const FormatException('Quick link svg does not contain an <svg> element');
  }
  return value;
}
