// FLUTTER / DART / THIRD-PARTIES
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Utils {
  /// Used to open a url
  static Future<void> launchURL(String url, AppIntl intl) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showToast(intl.error);
      throw 'Could not launch $url';
    }
  }
}
