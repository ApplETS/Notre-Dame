// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
// CONSTANT
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';

/// WARNING !!! THIS IS A CLASS IN DEVELOPMENT !!!  DO NOT USE!!
class GradeButton extends StatelessWidget {
  final String _codeTxt;
  final String _gradeTxt;
  final NavigationService _navigationService = locator<NavigationService>();

  GradeButton({@required String codeTxt, String gradeTxt = "N/A"})
      : assert(codeTxt != null),
        _codeTxt = codeTxt.toUpperCase(),
        _gradeTxt = gradeTxt.toUpperCase();
  static const double _buttonWidth = 70;
  static const double _codeHeight = 24;
  static const double _gradeHeight = _buttonWidth - _codeHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _setCodeSection(),
            _setGradeSection(),
          ],
        ),
      ),
    );
  }

  Container _setCodeSection() {
    return Container(
      width: _buttonWidth,
      height: _codeHeight,
      color: AppTheme.etsDarkRed,
      child: Center(
        child: Text(_codeTxt,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
            )),
      ),
    );
  }

  Container _setGradeSection() {
    // ignore: sized_box_for_whitespace
    return Container(
      width: _buttonWidth,
      height: _gradeHeight,
      child: Center(
        child: Text(_gradeTxt,
            style: const TextStyle(
              fontSize: 24,
              color: AppTheme.etsDarkGrey,
            )),
      ),
    );
  }

  void onPressed() {
    _navigationService.pushNamed('/', arguments: _codeTxt);
  }
}
