// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

import 'package:notredame/ui/utils/app_theme.dart';
import 'package:stacked/stacked.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/login_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/password_text_field.dart';

// GENERATED
import 'package:notredame/generated/l10n.dart';

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
            backgroundColor: AppTheme.etsLightRed,
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
                      child: FocusScope(
                        node: _focusNode,
                        child: Column(
                          children: [
                            Hero(
                              tag: 'ets_logo',
                              child: Image.asset(
                                'assets/images/ets_white_logo.png',
                                excludeFromSemantics: true,
                                width: 216,
                                height: 216,
                              ),
                            ),
                            TextFormField(
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
                                        color: Colors.amberAccent,
                                        width: borderRadiusOnFocus)),
                                errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.amberAccent,
                                        width: borderRadiusOnFocus)),
                                labelText: AppIntl.of(context)
                                    .login_prompt_universal_code,
                                labelStyle:
                                    const TextStyle(color: Colors.white54),
                                errorStyle:
                                    const TextStyle(color: Colors.amberAccent),
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
                                onEditionComplete: _focusNode.nextFocus),
                            const SizedBox(
                              height: 30.0,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: FlatButton(
                                onPressed: !model.canSubmit
                                    ? null
                                    : () async {
                                        final String error =
                                            await model.authenticate();

                                        setState(() {
                                          Scaffold.of(context).showSnackBar(
                                              SnackBar(content: Text(error)));
                                          formKey.currentState.reset();
                                        });
                                      },
                                disabledColor: Colors.white38,
                                color: Colors.white,
                                padding: const EdgeInsets.only(
                                    bottom: 16.0, top: 16.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
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

  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
