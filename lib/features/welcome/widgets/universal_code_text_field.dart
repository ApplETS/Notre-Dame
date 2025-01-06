// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/features/welcome/login/login_mask.dart';

class UniversalCodeFormField extends StatefulWidget {
  final FormFieldValidator<String> validator;
  final VoidCallback onEditionComplete;
  final String universalCode;

  const UniversalCodeFormField(
      {super.key,
      required this.validator,
      required this.onEditionComplete,
      required this.universalCode});

  @override
  State<UniversalCodeFormField> createState() => _UniversalCodeFormFieldState();
}

class _UniversalCodeFormFieldState extends State<UniversalCodeFormField> {
  /// Define if the password is visible or not
  final double borderRadiusOnFocus = 2.0;

  /// Unique key of the tooltip
  final GlobalKey<TooltipState> tooltipKey = GlobalKey<TooltipState>();

  @override
  Widget build(BuildContext context) => TextFormField(
        autofillHints: const [AutofillHints.username],
        cursorColor: Colors.white,
        keyboardType: TextInputType.visiblePassword,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white70)),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.white, width: borderRadiusOnFocus)),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: errorTextColor, width: borderRadiusOnFocus)),
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: errorTextColor, width: borderRadiusOnFocus)),
          labelText: AppIntl.of(context)!.login_prompt_universal_code,
          labelStyle: const TextStyle(color: Colors.white54),
          errorStyle: TextStyle(color: errorTextColor),
          suffixIcon: Tooltip(
              key: tooltipKey,
              triggerMode: TooltipTriggerMode.manual,
              message: AppIntl.of(context)!.universal_code_example,
              preferBelow: true,
              child: IconButton(
                icon: const Icon(Icons.help, color: Colors.white),
                onPressed: () {
                  tooltipKey.currentState?.ensureTooltipVisible();
                },
              )),
        ),
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        onEditingComplete: widget.onEditionComplete,
        validator: widget.validator,
        initialValue: widget.universalCode,
        inputFormatters: [
          LoginMask(),
        ],
      );

  Color get errorTextColor => Theme.of(context).brightness == Brightness.light
      ? Colors.amberAccent
      : Colors.redAccent;
}
