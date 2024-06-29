import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FaqTitle extends StatelessWidget {
  final Color? backgroundColor;

  const FaqTitle({this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Icon(
                  Icons.arrow_back,
                  color: backgroundColor == Colors.white
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              AppIntl.of(context)!.need_help,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: backgroundColor == Colors.white
                        ? Colors.black
                        : Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
