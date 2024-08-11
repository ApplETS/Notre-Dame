// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easter_egg_trigger/easter_egg_trigger.dart';

class EasterEggIcon extends StatelessWidget {
  final Function toggleTrigger;
  final bool easterEggTrigger;

  const EasterEggIcon(
      {required this.toggleTrigger, required this.easterEggTrigger});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EasterEggTrigger(
          // ignore: avoid_dynamic_calls
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
        if (easterEggTrigger)
          SizedBox(
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
      ],
    );
  }
}
