// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/welcome/widgets/forgot_password.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/welcome/login/login_viewmodel.dart';
import 'package:notredame/features/welcome/widgets/password_text_field.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/utils.dart';
import 'package:notredame/features/welcome/widgets/login_hero.dart';
import 'package:notredame/features/welcome/widgets/universal_code_text_field.dart';
import 'package:notredame/features/welcome/widgets/login_button.dart';
import 'package:notredame/features/welcome/widgets/login_footer.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final double borderRadiusOnFocus = 2.0;

  final FocusScopeNode _focusNode = FocusScopeNode();

  /// Unique key of the login form form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
                                    const SizedBox(
                                      height: 48,
                                    ),
                                    const LoginHero(),
                                    const SizedBox(
                                      height: 48,
                                    ),
                                    UniversalCodeFormField(
                                      validator: model.validateUniversalCode,
                                      onEditionComplete:
                                        _focusNode.nextFocus,
                                      universalCode: model.universalCode
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    PasswordFormField(
                                        validator: model.validatePassword,
                                        onEditionComplete:
                                            _focusNode.nextFocus),
                                    const ForgotPassword(),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                    LoginButton(
                                      formKey: formKey,
                                      canSubmit: model.canSubmit,
                                      authenticate: model.authenticate,
                                    ),
                                    const LoginFooter()
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Wrap(
                            direction: Axis.vertical,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: -20,
                            children: <Widget>[
                              Text(
                                AppIntl.of(context)!.login_applets_logo,
                                style: const TextStyle(color: Colors.white),
                              ),
                              Image.asset(
                                'assets/images/applets_white_logo.png',
                                excludeFromSemantics: true,
                                width: 100,
                                height: 100,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
        ),
      );

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
