// FLUTTER / DART / THIRD-PARTIES
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';

// OTHERS
import 'package:notredame/generated/l10n.dart';

class AboutView extends StatefulWidget {
  @override
  _AboutViewState createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> with TickerProviderStateMixin {
  AnimationController _controller;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completed = true;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(AppIntl.of(context).more_about_applets_title),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(children: [
        Positioned(
          top: -(MediaQuery.of(context).size.height / 2) - 100,
          bottom: 0,
          right: 0,
          left: 0,
          child: OverflowBox(
            maxHeight: MediaQuery.of(context).size.longestSide * 2,
            maxWidth: MediaQuery.of(context).size.longestSide * 2,
            minHeight: 0,
            minWidth: 0,
            child: AnimatedContainer(
              duration: const Duration(seconds: 3),
              width:
                  _completed ? MediaQuery.of(context).size.longestSide * 2 : 0,
              height:
                  _completed ? MediaQuery.of(context).size.longestSide * 2 : 0,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 25, 55, 95),
                  shape: BoxShape.circle),
            ),
          ),
        ),
        Positioned(
          top: 100,
          right: 0,
          left: 0,
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
                child: Text(
                  AppIntl.of(context).more_applets_about_details,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      icon: Image.asset("assets/images/website_white.png"),
                      onPressed: () => _launchURL("https://clubapplets.ca/")),
                  IconButton(
                      icon: Image.asset("assets/images/github_white.png"),
                      onPressed: () =>
                          _launchURL("https://github.com/ApplETS")),
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
      ]),
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
