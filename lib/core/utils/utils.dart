// FLUTTER / DART / THIRD-PARTIES
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// SERVICES
import 'package:notredame/core/services/networking_service.dart';

class Utils {
  /// Used to open a url
  static Future<void> launchURL(String url, AppIntl intl) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: intl.error);
      throw 'Could not launch $url';
    }
  }

  static Future showNoConnectionToast(
      NetworkingService networkingService, AppIntl intl) async {
    if (!await networkingService.hasConnectivity()) {
      Fluttertoast.showToast(msg: intl.no_connectivity);
    }
  }
}
