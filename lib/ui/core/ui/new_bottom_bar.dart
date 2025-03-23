import 'package:flutter/material.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';

import '../../../data/services/navigation_service.dart';
import '../../../domain/constants/router_paths.dart';
import '../../../locator.dart';

class NewBottomBar extends StatelessWidget {
  const NewBottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final NavigationService navigationService = locator<NavigationService>();

    return Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
      colors: [
        const Color(0xFF1A1A1D).withValues(alpha: 0),
        const Color(0xFF1A1A1D).withValues(alpha: 0.6),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,)),
      child: Stack(children: [
        Container(
          height: 48,
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: context.theme.appColors.appBar,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppPalette.etsDarkRed,
                spreadRadius: 1,
                blurRadius: 8,
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 46.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.dashboard),
                  onPressed: () {
                    navigationService.pushNamedAndRemoveDuplicates(RouterPaths.dashboard);
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRect(
                                clipper: _TopHalfClipper(),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppPalette.etsDarkRed,
                                        offset: Offset(0, 3),
                                        spreadRadius: 4,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppPalette.etsLightRed,
                                  iconColor: context.theme.appColors.backgroundAlt,
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(10)
                              ),
                              onPressed: () {
                                navigationService.pushNamedAndRemoveDuplicates(RouterPaths.schedule);
                              },
                              child: Icon(
                                  size: 24,
                                  color: Colors.white,
                                  Icons.watch_later_sharp
                              ),
                            ),
                          ],
                        ),
                      ),
                      FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            'Schedule',
                            style: TextStyle(height: 1, fontSize: 13),
                          )
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.school_outlined),
                  onPressed: () {
                    navigationService.pushNamedAndRemoveDuplicates(RouterPaths.student);
                  },
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.account_balance_outlined),
                  onPressed: () {
                    navigationService.pushNamedAndRemoveDuplicates(RouterPaths.ets);
                  },
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.menu_outlined),
                  onPressed: () {
                    navigationService.pushNamedAndRemoveDuplicates(RouterPaths.more);
                  },
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _TopHalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    // Only allow the top half of the shadow to be visible
    return Rect.fromLTWH(-10, -10, size.width + 20, size.height / 2 + 10);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}
