// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/login/view_model/login_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(intl: AppIntl.of(context)!),
      builder: (context, model, child) => Scaffold(
        backgroundColor: context.theme.appColors.backgroundVibrant,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'AppETS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: AppPalette.grey.white),
                ),
                Text(
                  'Veuillez vous authentifier pour continuer',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18, color: AppPalette.grey.white),
                ),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Nom d\'utilisateur', border: OutlineInputBorder()),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
                  obscureText: true,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: () {
                      // fait rient pour l'instant
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3B62FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Se connecter',
                      style: TextStyle(color: AppPalette.grey.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
