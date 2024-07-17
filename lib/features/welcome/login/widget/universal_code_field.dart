// widgets/UniversalCodeField.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/features/welcome/login/login_mask.dart';
import 'package:notredame/features/welcome/login/login_viewmodel.dart';
import 'package:notredame/utils/utils.dart';

class UniversalCodeField extends StatelessWidget {
  final double borderRadiusOnFocus;
  final GlobalKey<TooltipState> tooltipKey;
  final LoginViewModel model;

  const UniversalCodeField({
    super.key,
    required this.borderRadiusOnFocus,
    required this.tooltipKey,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
                color: errorTextColor(context), width: borderRadiusOnFocus)),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: errorTextColor(context), width: borderRadiusOnFocus)),
        labelText: AppIntl.of(context)!.login_prompt_universal_code,
        labelStyle: const TextStyle(color: Colors.white54),
        errorStyle: TextStyle(color: errorTextColor(context)),
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
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
      validator: model.validateUniversalCode,
      initialValue: model.universalCode,
      inputFormatters: [LoginMask()],
    );
  }

  Color errorTextColor(BuildContext context) =>
      Utils.getColorByBrightness(context, Colors.amberAccent, Colors.redAccent);
}
