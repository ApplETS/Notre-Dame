// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:notredame/generated/l10n.dart';

class AboutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      appBar: AppBar(
        title: Text(AppIntl.of(context).more_about_applets_title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            Hero(
              tag: 'about',
              child: Image.asset(
                "assets/images/favicon_applets.png",
                scale: 2.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(AppIntl.of(context).more_applets_about_details),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    icon: Image.asset("assets/images/website_white.png"),
                    onPressed: () => _launchURL("https://clubapplets.ca/")),
                IconButton(
                    icon: Image.asset("assets/images/github_white.png"),
                    onPressed: () => _launchURL("https://github.com/ApplETS")),
                IconButton(
                    icon: Image.asset("assets/images/facebook_white.png"),
                    onPressed: () =>
                        _launchURL("https://facebook.com/ClubApplETS")),
                IconButton(
                    icon: Image.asset("assets/images/twitter_white.png"),
                    onPressed: () =>
                        _launchURL("https://twitter.com/ClubApplETS")),
                IconButton(
                    icon: Image.asset("assets/images/youtube_white.png"),
                    onPressed: () => _launchURL(
                        "https://youtube.com/channel/UCiSzzfW1bVbE_0KcEZO52ew")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Used to open a url
Future<void> _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    showToast(AppIntl.current.error);
    throw 'Could not launch $url';
  }
}
