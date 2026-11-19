// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/models/quick_link_icons.dart';

void main() {
  const rawSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><rect width="10" height="10"/></svg>';

  group("validateQuickLinkSvg - ", () {
    test("returns the SVG markup trimmed.", () {
      expect(validateQuickLinkSvg('  $rawSvg  '), rawSvg);
    });

    test("throws a FormatException when there is no <svg> element.", () {
      expect(() => validateQuickLinkSvg('not an svg'), throwsFormatException);
      expect(() => validateQuickLinkSvg(''), throwsFormatException);
    });
  });

  group("buildQuickLinkImage - ", () {
    test("uses the library icon when the FontAwesomeIcons name is known.", () {
      expect(buildQuickLinkImage(icon: 'addressBook', svg: rawSvg), isA<FittedBox>());
    });

    test("ignores names that are not FontAwesomeIcons constant names.", () {
      expect(buildQuickLinkImage(icon: 'address-book', svg: rawSvg), isA<SvgPicture>());
    });

    test("uses the svg when there is no known icon.", () {
      expect(buildQuickLinkImage(svg: rawSvg), isA<SvgPicture>());
    });

    test("falls back to the placeholder when nothing is usable.", () {
      expect(buildQuickLinkImage(svg: 'not an svg'), isA<FittedBox>());
      expect(buildQuickLinkImage(), isA<FittedBox>());
    });
  });
}
