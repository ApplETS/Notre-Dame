// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/more/about/widget/easter_egg_icon.dart'; // Importez le widget extrait
import 'package:notredame/features/more/about/widget/social_icons_row.dart'; // Importez le widget extrait

class AboutView extends StatefulWidget {
  @override
  _AboutViewState createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> with TickerProviderStateMixin {
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
    return newMethod(context);
  }

  Scaffold newMethod(BuildContext context) {
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
              EasterEggIcon(
                toggleTrigger: toggleTrigger,
                easterEggTrigger: _easterEggTrigger,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppIntl.of(context)!.more_applets_about_details,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SocialIconsRow(),
            ],
          ),
        ),
      ]),
    );
  }
}
