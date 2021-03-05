// FLUTTER / DART / THIRD-PARTIES
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';

// OTHER
import 'package:notredame/generated/l10n.dart';

class Util {
  /// Used to open a url
  Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showToast(AppIntl.current.error);
      throw 'Could not launch $url';
    }
  }
}
