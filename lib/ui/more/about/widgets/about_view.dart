// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/domain/constants/urls.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
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
        foregroundColor: AppPalette.grey.white,
        title: Text(AppIntl.of(context)!.more_about_applets_title),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
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
                width: _completed ? MediaQuery.of(context).size.longestSide * 2 : 0,
                height: _completed ? MediaQuery.of(context).size.longestSide * 2 : 0,
                decoration: const BoxDecoration(color: Color.fromARGB(255, 25, 55, 95), shape: BoxShape.circle),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: 0,
            left: 0,
            child: Column(
              children: [
                easterEggLogo(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    AppIntl.of(context)!.more_applets_about_details,
                    style: TextStyle(color: AppPalette.grey.white),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.earthAmericas, color: AppPalette.grey.white),
                        tooltip: AppIntl.of(context)!.website_club_open,
                        onPressed: () => _launchUrlService.launchInBrowser(Urls.clubWebsite),
                      ),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.github, color: AppPalette.grey.white),
                        tooltip: AppIntl.of(context)!.github_open,
                        onPressed: () => _launchUrlService.launchInBrowser(Urls.clubGithub),
                      ),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.facebook, color: AppPalette.grey.white),
                        tooltip: AppIntl.of(context)!.facebook_open,
                        onPressed: () => _launchUrlService.launchInBrowser(Urls.clubFacebook),
                      ),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.youtube, color: AppPalette.grey.white),
                        tooltip: AppIntl.of(context)!.youtube_open,
                        onPressed: () => _launchUrlService.launchInBrowser(Urls.clubYoutube),
                      ),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.discord, color: AppPalette.grey.white),
                        tooltip: AppIntl.of(context)!.discord_join,
                        onPressed: () => _launchUrlService.launchInBrowser(Urls.clubDiscord),
                      ),
                    ],
                  ),
                ),
                if (_easterEggTrigger)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: SizedBox(
                      width: 128,
                      height: 128,
                      child: Hero(tag: 'capra', child: Image.asset("assets/images/capra.png", scale: 1.0)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget easterEggLogo() {
    final Duration delay = Duration(seconds: 2);
    final List<AxisDirection> combinaison = [
      AxisDirection.up,
      AxisDirection.right,
      AxisDirection.down,
      AxisDirection.left,
    ];

    DateTime? lastCodeDate;
    List<AxisDirection> currentCombinaison = [];

    void addCode(AxisDirection code) {
      if (DateTime.now().difference(lastCodeDate ?? DateTime.now()).compareTo(delay) > 0) currentCombinaison = [];
      currentCombinaison.add(code);
      lastCodeDate = DateTime.now();
      if (currentCombinaison.length > combinaison.length) currentCombinaison.removeAt(0);
    }

    void onVerticalDragEnd(DragEndDetails details) =>
        addCode(details.primaryVelocity! > 0.0 ? AxisDirection.down : AxisDirection.up);

    void onHorizontalDragEnd(DragEndDetails details) =>
        addCode(details.primaryVelocity! > 0.0 ? AxisDirection.right : AxisDirection.left);

    return GestureDetector(
      onVerticalDragEnd: onVerticalDragEnd,
      onHorizontalDragEnd: onHorizontalDragEnd,
      onTap: () {
        if (listEquals(combinaison, currentCombinaison)) toggleTrigger();
      },
      child: logo(),
    );
  }

  Widget logo() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Hero(tag: 'about', child: Image.asset("assets/images/favicon_applets.png", scale: 2.0)),
    );
  }
}
