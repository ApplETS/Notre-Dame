// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';

class NavigationMenuButton extends StatefulWidget {
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final VoidCallback onPressed;

  const NavigationMenuButton(
      {super.key, required this.label, required this.activeIcon, required this.inactiveIcon, required this.onPressed});

  @override
  State<NavigationMenuButton> createState() => NavigationMenuButtonState();
}

class NavigationMenuButtonState extends State<NavigationMenuButton> with TickerProviderStateMixin {
  late final AnimationController _paddingController;
  late final AnimationController _buttonColorController;
  late final AnimationController _textOpacityController;

  bool _isActive = false;

  @override
  void initState() {
    super.initState();

    _buttonColorController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _paddingController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _textOpacityController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _paddingController.dispose();
    _buttonColorController.dispose();
    _textOpacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return AnimatedBuilder(
      animation: _paddingController,
      builder: (BuildContext context, Widget? child) {
        double offset = portrait ? 32.0 : 8.0;
        return Transform.translate(
          offset: Offset(0.0, _paddingController.value * -offset),
          child: child,
        );
      },
      child: Column(
        children: [
          Stack(
            children: [
              if (portrait)
                Positioned.fill(
                  child: ClipRect(
                    clipper: _TopHalfClipper(),
                    child: AnimatedContainer(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _isActive ? AppPalette.etsLightRed : Colors.transparent,
                            offset: const Offset(0.0, 3.0),
                            spreadRadius: -3.0,
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      duration: Duration(milliseconds: 200),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: AnimatedBuilder(
                  animation: _buttonColorController,
                  builder: (BuildContext context, Widget? child) {
                    Color backgroundColor = ColorTween(
                      begin: Colors.transparent,
                      end: AppPalette.etsLightRed,
                    ).animate(_buttonColorController).value!;
                    return ElevatedButton(
                      onPressed: () => widget.onPressed(),
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: backgroundColor,
                          shadowColor: AppPalette.etsDarkRed,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10.0)),
                      child: Icon(
                        _isActive ? widget.activeIcon : widget.inactiveIcon,
                        size: 24.0,
                        color: _isActive ? Colors.white : context.theme.textTheme.bodyMedium!.color,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          FadeTransition(
            opacity: _textOpacityController,
            child: Text(
              widget.label,
              style: TextStyle(fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }

  void reverseAnimation() {
    setState(() => _isActive = false);
    _textOpacityController.reverse().then((_) {
      _buttonColorController.reverse();
      _paddingController.reverse();
    });
  }

  void restartAnimation() {
    _buttonColorController.forward();
    _paddingController.forward().then((_) {
      setState(() => _isActive = true);
      _textOpacityController.forward();
    });
  }
}

class _TopHalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    // Only allow the top half of the shadow to be visible
    return Rect.fromLTWH(-10.0, -10.0, size.width + 20.0, (size.height / 2.0) + 14.0);
  }

  @override
  bool shouldReclip(_) => false;
}
