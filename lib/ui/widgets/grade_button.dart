// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class GradeButton extends StatelessWidget {
  String _codeTxt = 'LOG121';
  String _gradeTxt = 'A+';
  final double _buttonWidth = 70;
  final double _codeHeight = 24;
  double _gradeHeight = 0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: RaisedButton(
        padding: const EdgeInsets.all(0.0),
        onPressed: () {},
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

  GradeButton(this._codeTxt, this._gradeTxt) {
    _gradeHeight = _buttonWidth - _codeHeight;
  }
}
