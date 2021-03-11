// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:stacked/stacked.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/login_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/password_text_field.dart';

// OTHER
import 'package:notredame/ui/utils/app_theme.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final double borderRadiusOnFocus = 2.0;

  final FocusScopeNode _focusNode = FocusScopeNode();

  /// Unique key of the login form form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<LoginViewModel>.reactive(
        viewModelBuilder: () => LoginViewModel(intl: AppIntl.of(context)),
        builder: (context, model, child) => Scaffold(
            backgroundColor: model.getAppTheme() == ThemeMode.light.toString()
                ? AppTheme.etsLightRed
                : model.getAppTheme() == ThemeMode.dark.toString()
                    ? AppTheme.primaryDark
                    : Theme.of(context).brightness == Brightness.light
                        ? AppTheme.etsLightRed
                        : AppTheme.primaryDark,
            resizeToAvoidBottomInset: false,
            body: Builder(
              builder: (BuildContext context) => SafeArea(
                minimum: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Form(
                      key: formKey,
                      onChanged: () {
                        setState(() {
                          formKey.currentState.validate();
                        });
                      },
                      child: AutofillGroup(
                        child: FocusScope(
                          node: _focusNode,
                          child: Column(
                            children: [
                              Hero(
                                tag: 'ets_logo',
                                child: Image.asset(
                                  model.getAppTheme() ==
                                          ThemeMode.light.toString()
                                      ? "assets/images/ets_white_logo.png"
                                      : model.getAppTheme() ==
                                              ThemeMode.dark.toString()
                                          ? "assets/images/ets_red_logo.png"
                                          : Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? "assets/images/ets_white_logo.png"
                                              : "assets/images/ets_red_logo.png",
                                  excludeFromSemantics: true,
                                  width: 216,
                                  height: 216,
                                ),
                              ),
                              TextFormField(
                                autofillHints: const [AutofillHints.username],
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  enabledBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white70)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white,
                                          width: borderRadiusOnFocus)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: getErrorTextColor(
                                              model.getAppTheme()),
                                          width: borderRadiusOnFocus)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: getErrorTextColor(
                                              model.getAppTheme()),
                                          width: borderRadiusOnFocus)),
                                  labelText: AppIntl.of(context)
                                      .login_prompt_universal_code,
                                  labelStyle:
                                      const TextStyle(color: Colors.white54),
                                  errorStyle: TextStyle(
                                      color: getErrorTextColor(
                                          model.getAppTheme())),
                                ),
                                autofocus: true,
                                style: const TextStyle(color: Colors.white),
                                onEditingComplete: _focusNode.nextFocus,
                                validator: model.validateUniversalCode,
                                initialValue: model.universalCode,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              PasswordFormField(
                                  validator: model.validatePassword,
                                  onEditionComplete: _focusNode.nextFocus,
                                  appTheme: model.getAppTheme()),
                              const SizedBox(
                                height: 30.0,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: !model.canSubmit
                                      ? null
                                      : () async {
                                          final String error =
                                              await model.authenticate();

                                          setState(() {
                                            if (error.isNotEmpty) {
                                              showToast(error);
                                            }
                                            formKey.currentState.reset();
                                          });
                                        },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.disabled)) {
                                          return model.getAppTheme() ==
                                                  ThemeMode.light.toString()
                                              ? Colors.white38
                                              : model.getAppTheme() ==
                                                      ThemeMode.dark.toString()
                                                  ? Colors.grey[800]
                                                  : Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.white38
                                                      : Colors.grey[800];
                                        }
                                        return model.getAppTheme() ==
                                                ThemeMode.light.toString()
                                            ? Colors.white
                                            : model.getAppTheme() ==
                                                    ThemeMode.dark.toString()
                                                ? Colors.grey[900]
                                                : Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? Colors.white
                                                    : Colors.grey[900];
                                      },
                                    ),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            vertical: 16)),
                                  ),
                                  child: Text(
                                    AppIntl.of(context).login_action_sign_in,
                                    style: const TextStyle(
                                        color: Color.fromRGBO(239, 62, 69, 1),
                                        fontSize: 18),
                                  ),
                                ),
                              )
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
                          AppIntl.of(context).login_applets_logo,
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
      );

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Color getErrorTextColor(String appTheme) {
    return appTheme == ThemeMode.light.toString()
        ? Colors.amberAccent
        : appTheme == ThemeMode.dark.toString()
            ? Colors.redAccent
            : Theme.of(context).brightness == Brightness.light
                ? Colors.amberAccent
                : Colors.redAccent;
  }
}
