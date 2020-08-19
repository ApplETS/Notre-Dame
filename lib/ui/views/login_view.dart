// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
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
        viewModelBuilder: () => LoginViewModel(
            intl: AppIntl.of(context)),
        builder: (context, model, child) => Scaffold(
            resizeToAvoidBottomInset: false,
            body: Builder(
              builder: (BuildContext context) => Container(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 20.0, bottom: 60.0),
                color: const Color.fromRGBO(239, 62, 69, 1),
                child: Form(
                  key: formKey,
                  onChanged: () {
                    setState(() {
                      formKey.currentState.validate();
                    });
                  },
                  child: FocusScope(
                    node: _focusNode,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/ets_white_logo.png',
                          excludeFromSemantics: true,
                          width: 216,
                          height: 216,
                        ),
                        TextFormField(
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70)),
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
                            labelText:
                                AppIntl.of(context).login_prompt_universal_code,
                            labelStyle: TextStyle(color: Colors.white54),
                            errorStyle: TextStyle(color: Colors.amberAccent),
                          ),
                          autofocus: true,
                          style: TextStyle(color: Colors.white),
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
                                    final String error = await model.authenticate();

                                    setState(() {
                                      Scaffold.of(context).showSnackBar(
                                          SnackBar(content: Text(error)));
                                      formKey.currentState.reset();
                                    });
                                  },
                            disabledColor: Colors.white38,
                            color: Colors.white,
                            padding:
                                const EdgeInsets.only(bottom: 16.0, top: 16.0),
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
              ),
            )),
      );

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
