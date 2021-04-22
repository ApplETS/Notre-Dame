// FLUTTER / DART / THIRD-PARTIES
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  static double getGradeInPercentage(double grade, double maxGrade) {
    if (grade == null || maxGrade == null || grade == 0.0 || maxGrade == 0.0) {
      return 0.0;
    }

    return ((grade / maxGrade) * 100).roundToDouble();
  }
}
