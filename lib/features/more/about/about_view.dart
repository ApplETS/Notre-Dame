// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easter_egg_trigger/easter_egg_trigger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:notredame/constants/urls.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/features/app/integration/launch_url_service.dart';

class AboutView extends StatefulWidget {
  @override
  _AboutViewState createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> with TickerProviderStateMixin {
  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();
  late AnimationController _controller;
  bool _completed = false;
  bool _easterEggTrigger = false;

  void toggleTrigger() {
    setState(() {
      _easterEggTrigger = !_easterEggTrigger;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _completed = true;
        });
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
        foregroundColor: Colors.white,
        title: Text(
          AppIntl.of(context)!.more_about_applets_title,
        ),
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
              duration: const Duration(seconds: 1),
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
              EasterEggTrigger(
                action: () => toggleTrigger(),
                codes: const [
                  EasterEggTriggers.SwipeUp,
                  EasterEggTriggers.SwipeRight,
                  EasterEggTriggers.SwipeDown,
                  EasterEggTriggers.SwipeLeft,
                  EasterEggTriggers.Tap
                ],
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Hero(
                    tag: 'about',
                    child: Image.asset(
                      "assets/images/favicon_applets.png",
                      scale: 2.0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppIntl.of(context)!.more_applets_about_details,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.earthAmericas,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            _launchUrlService.launchInBrowser(Urls.clubWebsite)),
                    IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.github,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            _launchUrlService.launchInBrowser(Urls.clubGithub)),
                    IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.facebook,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            _launchUrlService.launchInBrowser(Urls.clubFacebook)),
                    IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.twitter,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            _launchUrlService.launchInBrowser(Urls.clubTwitter)),
                    IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.youtube,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            _launchUrlService.launchInBrowser(Urls.clubYoutube)),
                    IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.discord,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            _launchUrlService.launchInBrowser(Urls.clubDiscord)),
                  ],
                ),
              ),
              if (_easterEggTrigger)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: SizedBox(
                    width: 128,
                    height: 128,
                    child: Hero(
                      tag: 'capra',
                      child: Image.asset(
                        "assets/images/capra.png",
                        scale: 1.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}
