import 'package:flutter/material.dart';

import '../../core/themes/app_palette.dart';

class WidgetComponent extends StatelessWidget {
  final Widget _childWidget;
  final String _title;

  const WidgetComponent({
    super.key,
    Widget? childWidget,
    required String title,
  })  : _title = title,
        _childWidget = childWidget ??
            const SizedBox(
              height: 125,
              child: Text(
                "TODO",
                style: TextStyle(color: Colors.white),
              ),
            );

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(16, 13, 16, 13),
          color: AppPalette.grey.darkGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    color: AppPalette.grey.darkGrey,
                  ),
                  child: Container(
                    color: AppPalette.etsLightRed,
                    height: 35,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _childWidget,
              ),
            ],
          ),
        ));
  }
}
