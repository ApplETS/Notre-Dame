// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// SERVICE
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/launch_url_service.dart';
import 'package:notredame/core/services/launch_url_in_browser_service.dart';

// UTILS
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/core/utils/login_mask.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/login_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/password_text_field.dart';

// CONSTANTS
import 'package:notredame/core/constants/app_info.dart';

// OTHER
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/locator.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final String forgotPasswordLink =
      "https://signets-ens.etsmtl.ca/Public/MotDePassePerdu.aspx";

  final double borderRadiusOnFocus = 2.0;

  final FocusScopeNode _focusNode = FocusScopeNode();

  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();

  /// Unique key of the login form form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Unique key of the tooltip
  final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<LoginViewModel>.reactive(
        viewModelBuilder: () => LoginViewModel(intl: AppIntl.of(context)),
        builder: (context, model, child) => Scaffold(
            backgroundColor: Utils.getColorByBrightness(
                context, AppTheme.etsLightRed, AppTheme.primaryDark),
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
                              const SizedBox(
                                height: 48,
                              ),
                              Hero(
                                  tag: 'ets_logo',
                                  child: SvgPicture.asset(
                                    "assets/images/ets_white_logo.svg",
                                    excludeFromSemantics: true,
                                    width: 90,
                                    height: 90,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.white
                                        : AppTheme.etsLightRed,
                                  )),
                              const SizedBox(
                                height: 48,
                              ),
                              TextFormField(
                                autofillHints: const [AutofillHints.username],
                                cursorColor: Colors.white,
                                keyboardType: TextInputType.visiblePassword,
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
                                          color: errorTextColor,
                                          width: borderRadiusOnFocus)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: errorTextColor,
                                          width: borderRadiusOnFocus)),
                                  labelText: AppIntl.of(context)
                                      .login_prompt_universal_code,
                                  labelStyle:
                                      const TextStyle(color: Colors.white54),
                                  errorStyle: TextStyle(color: errorTextColor),
                                  suffixIcon: Tooltip(
                                      key: tooltipkey,
                                      triggerMode: TooltipTriggerMode.manual,
                                      message: AppIntl.of(context)
                                          .universal_code_example,
                                      preferBelow: true,
                                      child: IconButton(
                                        icon: const Icon(Icons.help,
                                            color: Colors.white),
                                        onPressed: () {
                                          tooltipkey.currentState
                                              ?.ensureTooltipVisible();
                                        },
                                      )),
                                ),
                                autofocus: true,
                                style: const TextStyle(color: Colors.white),
                                onEditingComplete: _focusNode.nextFocus,
                                validator: model.validateUniversalCode,
                                initialValue: model.universalCode,
                                inputFormatters: [
                                  LoginMask(),
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              PasswordFormField(
                                  validator: model.validatePassword,
                                  onEditionComplete: _focusNode.nextFocus),
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: InkWell(
                                    child: Text(
                                      AppIntl.of(context).forgot_password,
                                      style: const TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Colors.white),
                                    ),
                                    onTap: () {
                                      launchInBrowser(forgotPasswordLink);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 24,
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
                                              Fluttertoast.showToast(
                                                  msg: error);
                                            }
                                            formKey.currentState.reset();
                                          });
                                        },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        model.canSubmit
                                            ? colorButton
                                            : Colors.white38),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            vertical: 16)),
                                  ),
                                  child: Text(
                                    AppIntl.of(context).login_action_sign_in,
                                    style: TextStyle(
                                        color: model.canSubmit
                                            ? submitTextColor
                                            : Colors.white60,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 24),
                                  child: InkWell(
                                    child: Text(
                                      AppIntl.of(context).need_help_contact_us,
                                      style: const TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Colors.white),
                                    ),
                                    onTap: () async {
                                      sendEmail(model);
                                    },
                                  ),
                                ),
                              ),
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

  Color get errorTextColor =>
      Utils.getColorByBrightness(context, Colors.amberAccent, Colors.redAccent);

  Color get colorButton =>
      Utils.getColorByBrightness(context, Colors.white, AppTheme.etsLightRed);

  Color get submitTextColor =>
      Utils.getColorByBrightness(context, AppTheme.etsLightRed, Colors.white);

  Future<void> sendEmail(LoginViewModel model) async {
    final clubEmail =
        model.mailtoStr(AppInfo.email, AppIntl.of(context).email_subject);
    final urlLaunchable = await _launchUrlService.canLaunch(clubEmail);

    if (urlLaunchable) {
      await _launchUrlService.launch(clubEmail);
    } else {
      locator<AnalyticsService>().logError("login_view", "Cannot send email.");
    }
  }
}
