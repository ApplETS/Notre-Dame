// Dart imports:
import 'dart:convert';

/// A quick link as described in the `quicklinks_values` Firebase Remote Config parameter.
///
/// Expected JSON for one link (either `icon` OR `svg`, never both):
/// ```json
/// {
///   "id": 3,
///   "nameFr": "Bibliotech",
///   "nameEn": "Bibliotech",
///   "icon": "book",                 // FontAwesomeIcons constant name (see quickLinkIcons in quick_link_icons.dart)
///   "svg": "<svg ...>...</svg>",    // OR a raw SVG string
///   "link": "https://www.etsmtl.ca/Bibliotheque/Accueil"  // opened in the browser
/// }
/// ```
/// If neither `icon` nor `svg` is usable, a placeholder icon is displayed.
class QuickLinkRemoteData {
  final int id;
  final String nameFr;
  final String nameEn;
  final String? icon;
  final String? svg;
  final String link;

  QuickLinkRemoteData({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    required this.link,
    this.icon,
    this.svg,
  });

  factory QuickLinkRemoteData.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final int? id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    final nameFr = json['nameFr'];
    final nameEn = json['nameEn'];
    final link = json['link'];

    if (id == null || nameFr is! String || nameEn is! String || link is! String || link.isEmpty) {
      throw FormatException('Invalid quick link entry: $json');
    }

    String? nonEmpty(dynamic value) => value is String && value.trim().isNotEmpty ? value.trim() : null;

    return QuickLinkRemoteData(
      id: id,
      nameFr: nameFr,
      nameEn: nameEn,
      link: link,
      icon: nonEmpty(json['icon']),
      svg: nonEmpty(json['svg']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameFr': nameFr,
    'nameEn': nameEn,
    if (icon != null) 'icon': icon,
    if (svg != null) 'svg': svg,
    'link': link,
  };

  /// Parse the whole Remote Config value.
  ///
  /// Throws a [FormatException] if the value is not a JSON list.
  /// Invalid entries and duplicated ids are skipped so one bad entry does not break every link.
  static List<QuickLinkRemoteData> listFromJsonString(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! List) {
      throw const FormatException('quicklinks_values must be a JSON list');
    }

    final result = <QuickLinkRemoteData>[];
    final seenIds = <int>{};
    for (final entry in decoded) {
      if (entry is! Map<String, dynamic>) continue;
      try {
        final data = QuickLinkRemoteData.fromJson(entry);
        if (seenIds.add(data.id)) result.add(data);
      } on FormatException {
        continue;
      }
    }
    return result;
  }
}
