// FLUTTER / DART / THIRD-PARTIES
import 'package:url_launcher/url_launcher.dart';

class LaunchUrlService {
  
  Future<bool> canLaunchUrl(String url) async {
    return canLaunch(url);
  }

  Future<bool> launchUrl(String url) async {
    return launch(url);
  }
}
