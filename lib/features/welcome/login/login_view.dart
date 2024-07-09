// LoginView.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/welcome/login/widget/app_ets_logo.dart';
import 'package:notredame/features/welcome/login/widget/forgot_password_link.dart';
import 'package:notredame/features/welcome/login/widget/login_button.dart';
import 'package:notredame/features/welcome/login/widget/login_widget.dart';
import 'package:notredame/features/welcome/login/widget/need_help_link.dart';
import 'package:notredame/features/welcome/login/widget/universal_code_field.dart';
import 'package:stacked/stacked.dart';

import 'package:notredame/features/welcome/login/login_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/utils.dart';
import 'package:notredame/features/welcome/widgets/password_text_field.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final double borderRadiusOnFocus = 2.0;

  final FocusScopeNode _focusNode = FocusScopeNode();

  /// Unique key of the login form form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Unique key of the tooltip
  final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<LoginViewModel>.reactive(
        viewModelBuilder: () => LoginViewModel(intl: AppIntl.of(context)!),
        builder: (context, model, child) => Scaffold(
          backgroundColor: Utils.getColorByBrightness(
              context, AppTheme.etsLightRed, AppTheme.primaryDark),
          resizeToAvoidBottomInset: false,
          body: Builder(
            builder: (BuildContext context) => SafeArea(
              minimum: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Form(
                      key: formKey,
                      onChanged: () {
                        setState(() {
                          formKey.currentState?.validate();
                        });
                      },
                      child: AutofillGroup(
                        child: FocusScope(
                          node: _focusNode,
                          child: Column(
                            children: [
                              const SizedBox(height: 48),
                              const LogoWidget(),
                              const SizedBox(height: 48),
                              UniversalCodeField(
                                borderRadiusOnFocus: borderRadiusOnFocus,
                                tooltipKey: tooltipkey,
                                model: model,
                              ),
                              const SizedBox(height: 16),
                              PasswordFormField(
                                  validator: model.validatePassword,
                                  onEditionComplete: _focusNode.nextFocus),
                              ForgotPasswordLink(),
                              const SizedBox(height: 24),
                              LoginButton(formKey: formKey, model: model),
                              NeedHelpLink(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const AppEtsLogo(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
