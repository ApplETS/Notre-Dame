// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';

/// Icons that can be referenced by name (`"icon": "<name>"`) in the `quicklinks_values` Remote Config.
///
/// Names follow the Font Awesome naming (https://fontawesome.com/icons).
/// The list is explicit on purpose: using the full Font Awesome name mapping would disable icon tree shaking.
/// To make a new icon available, add it here (requires an app release).
const Map<String, IconData> quickLinkIcons = {
  'address-book': FontAwesomeIcons.addressBook,
  'address-card': FontAwesomeIcons.addressCard,
  'book': FontAwesomeIcons.book,
  'book-open': FontAwesomeIcons.bookOpen,
  'briefcase': FontAwesomeIcons.briefcase,
  'building-columns': FontAwesomeIcons.buildingColumns,
  'bus': FontAwesomeIcons.bus,
  'calendar': FontAwesomeIcons.calendar,
  'calendar-days': FontAwesomeIcons.calendarDays,
  'circle-info': FontAwesomeIcons.circleInfo,
  'circle-question': FontAwesomeIcons.circleQuestion,
  'comments': FontAwesomeIcons.comments,
  'envelope': FontAwesomeIcons.envelope,
  'flask': FontAwesomeIcons.flask,
  'globe': FontAwesomeIcons.globe,
  'graduation-cap': FontAwesomeIcons.graduationCap,
  'handshake': FontAwesomeIcons.solidHandshake,
  'house': FontAwesomeIcons.house,
  'laptop': FontAwesomeIcons.laptop,
  'link': FontAwesomeIcons.link,
  'map-location-dot': FontAwesomeIcons.mapLocationDot,
  'newspaper': FontAwesomeIcons.newspaper,
  'people-roof': FontAwesomeIcons.peopleRoof,
  'phone': FontAwesomeIcons.phone,
  'print': FontAwesomeIcons.print,
  'sack-dollar': FontAwesomeIcons.sackDollar,
  'shield-halved': FontAwesomeIcons.shieldHalved,
  'user-graduate': FontAwesomeIcons.userGraduate,
  'user-tie': FontAwesomeIcons.userTie,
  'users': FontAwesomeIcons.users,
  'utensils': FontAwesomeIcons.utensils,
};

/// Icon displayed when a link has no usable icon/svg (unknown icon name, missing or broken svg).
Widget quickLinkPlaceholderIcon() =>
    const FittedBox(child: FaIcon(FontAwesomeIcons.link, color: AppPalette.etsLightRed));

/// Build the image of a quick link: library icon first, then raw svg, then the placeholder.
Widget buildQuickLinkImage({String? icon, String? svg}) {
  final iconData = icon != null ? quickLinkIcons[icon] : null;
  if (iconData != null) {
    return FittedBox(child: FaIcon(iconData, color: AppPalette.etsLightRed));
  }

  if (svg != null && svg.contains('<svg')) {
    return SvgPicture.string(svg, errorBuilder: (context, error, stackTrace) => quickLinkPlaceholderIcon());
  }

  return quickLinkPlaceholderIcon();
}
