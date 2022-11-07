// FLUTTER / DART / THIRD-PARTIES
import 'package:url_launcher/url_launcher.dart';

class LaunchUrlService {
  Future<bool> canLaunch(String url) async {
    final uri = Uri.parse(url);
    return canLaunchUrl(uri);
  }

  Future<bool> launch(String url) async {
    final uri = Uri.parse(url);
    return launchUrl(uri);
  }
}
