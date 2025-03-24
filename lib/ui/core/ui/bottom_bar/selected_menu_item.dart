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

class _SelectedMenuItemState extends State<SelectedMenuItem>
    with TickerProviderStateMixin {
  late final AnimationController _paddingController;
  late final Animation<double> _paddingAnimation;

  late final AnimationController _buttonController;
  late final Animation<Color?> _buttonColorAnimation;

  late final AnimationController _shadowController;
  late final Animation<Color?> _shadowColorAnimation;

  late final AnimationController _textController;
  late final Animation<Color?> _textColorAnimation;

  @override
  void initState() {
    super.initState();

    _paddingController = _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _paddingAnimation = Tween<double>(begin: 40, end: 16).animate(
        CurvedAnimation(parent: _paddingController, curve: Curves.easeOut))
      ..addListener(() => setState(() {}));

    _buttonColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: AppPalette.etsLightRed,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeIn,
    ))..addListener(() => setState(() {}));

    _shadowController = _textController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _shadowColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: AppPalette.etsDarkRed,
    ).animate(CurvedAnimation(
      parent: _shadowController,
      curve: Curves.easeIn,
    ))..addListener(() => setState(() {}));

    _textColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ))..addListener(() => setState(() {}));

    _buttonController.forward();
    _paddingController.forward().then((_) => {
      _shadowController.forward(),
      _textController.forward()
    });
  }

  @override
  void dispose() {
    _paddingController.dispose();
    _shadowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: EdgeInsets.only(top: _paddingAnimation.value),
      child: Column(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: ClipRect(
                  clipper: _TopHalfClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _shadowColorAnimation.value!,
                          offset: const Offset(0, 3),
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
                    backgroundColor: _buttonColorAnimation.value,
                    iconColor: context.theme.appColors.backgroundAlt,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10)),
                onPressed: () {},
                child: Icon(size: 24, color: Colors.white, widget.icon),
              ),
            ],
          ),
          FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                widget.label,
                style: TextStyle(
                  color: _textColorAnimation.value,
                    fontSize: 14
                ),
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
