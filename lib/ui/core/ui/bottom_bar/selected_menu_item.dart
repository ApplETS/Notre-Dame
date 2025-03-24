import 'package:flutter/material.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

class SelectedMenuItem extends StatefulWidget {
  final String label;
  final IconData icon;

  const SelectedMenuItem(
      {super.key,
        required this.label,
        required this.icon,
      });

  @override
  State<SelectedMenuItem> createState() => _SelectedMenuItemState();
}

class _SelectedMenuItemState extends State<SelectedMenuItem> {
  @override
  Widget build(BuildContext context) => Expanded(
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
                        padding: EdgeInsets.all(10)),
                    onPressed: () {},
                    child: Icon(size: 24, color: Colors.white, widget.icon),
                  ),
                ],
              ),
            ),
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  widget.label,
                  style: TextStyle(height: 1, fontSize: 13),
                )),
          ],
        ),
      ),
    );
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
