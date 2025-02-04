// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/data/repositories/login_mask.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';

class UniversalCodeFormField extends StatefulWidget {
  final FormFieldValidator<String> validator;
  final VoidCallback onEditionComplete;
  final String universalCode;

  const UniversalCodeFormField({
        super.key,
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
        autofillHints: const [
          AutofillHints.username
        ],
        cursorColor: AppPalette.grey.white,
        keyboardType:
        TextInputType.visiblePassword,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.white70)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppPalette.grey.white,
                  width: borderRadiusOnFocus)),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: context.theme.appColors.inputError,
                  width: borderRadiusOnFocus)),
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: context.theme.appColors.inputError,
                  width: borderRadiusOnFocus)),
          labelText: AppIntl.of(context)!
              .login_prompt_universal_code,
          labelStyle: const TextStyle(
              color: Colors.white54),
          errorStyle:
          TextStyle(color: context.theme.appColors.inputError),
          suffixIcon: Tooltip(
              key: tooltipKey,
              triggerMode:
              TooltipTriggerMode.manual,
              message: AppIntl.of(context)!
                  .universal_code_example,
              preferBelow: true,
              child: IconButton(
                icon: Icon(Icons.help,
                    color: AppPalette.grey.white),
                onPressed: () {
                  tooltipKey.currentState
                      ?.ensureTooltipVisible();
                },
              )),
        ),
        autofocus: true,
        style:
        TextStyle(color: AppPalette.grey.white),
        onEditingComplete: widget.onEditionComplete,
        validator: widget.validator,
        initialValue: widget.universalCode,
        inputFormatters: [
          LoginMask(),
        ],
      );
}
