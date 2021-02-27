// FLUTTER / DART / THIRD-PARTIES
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:github/github.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// ROUTER
import 'package:notredame/ui/router.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/analytics_service.dart';

// UTILS
import 'package:notredame/locator.dart';
import 'package:notredame/generated/l10n.dart';
import 'package:notredame/ui/utils/app_theme.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';

// VIEW
import 'package:notredame/ui/views/startup_view.dart';

void main() {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(() {
  runApp(
    BetterFeedback(
      translation: Translation(),
      onFeedback: (
        BuildContext context,
        String feedbackText,
        Uint8List feedbackScreenshot,
      ) async {
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final File file = await _localFile;
        await file.writeAsBytes(feedbackScreenshot);

        /// Create a GitHub Client, then send issue
        const String githubApiToken = String.fromEnvironment('GITHUB_API_TOKEN');
         final github = GitHub(auth: Authentication.withToken(githubApiToken));

         /// Upload picture to repo
          github.repositories
             .createFile(RepositorySlug.full('ApplETS/Notre-Dame-Bug-report'),
             CreateFile(path: file.path.replaceFirst('storage/emulated/0/Android/data/ca.etsmtl.applets.notredame/files/', ''),content: base64Encode(file.readAsBytesSync()).toString(),message: DateTime.now().toString(),committer: CommitUser('clubapplets-server', 'clubapplets@gmail.com'), branch: 'main'));

        /// Create issue
        github
            .issues
            .create(
                RepositorySlug.full("ApplETS/Notre-Dame"),
                IssueRequest(
                    title: 'Issue from ${packageInfo.appName} ',
                    body: " **Describe the issue** \n"
                        "```$feedbackText```\n\n"
                        "**Screenshot** \n"
                        "![screenshot](https://github.com/ApplETS/Notre-Dame-Bug-report/blob/main/${file.path.replaceFirst('storage/emulated/0/Android/data/ca.etsmtl.applets.notredame/files/', '')}?raw=true)\n\n"
                        "**Device Infos** \n"
                        "- **App name:** ${packageInfo.appName} \n"
                        "- **Package name:** ${packageInfo.packageName}  \n"
                        "- **Version:** ${packageInfo.version} \n"
                        "- **Build number:** ${packageInfo.buildNumber} \n"
                        "- **Platform operating system:** ${Platform.operatingSystem} \n"
                        "- **Platform operating system version:** ${Platform.operatingSystemVersion} \n",
                    labels: ['bug', 'platform: ${Platform.operatingSystem}']));
        file.deleteSync();
        showToast(
          AppIntl.current?.thankYouForTheFeedback,
          position: ToastPosition.center,
        );
        BetterFeedback.of(context).hide();
      },
      child: ETSMobile(),
    ),
  );}, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class ETSMobile extends StatefulWidget {
  @override
  _ETSMobileState createState() => _ETSMobileState();
}

class _ETSMobileState extends State<ETSMobile> {
  /// Manage the settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  @override
  void initState() {
    super.initState();
    _settingsManager.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      backgroundColor: Colors.grey,
      duration: const Duration(seconds: 3),
      position: ToastPosition.bottom,
      child: MaterialApp(
        title: 'ÉTS Mobile',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _settingsManager.themeMode,
        localizationsDelegates: const [
          AppIntl.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: _settingsManager?.locale,
        supportedLocales: AppIntl.delegate.supportedLocales,
        navigatorKey: locator<NavigationService>().navigatorKey,
        navigatorObservers: [
          locator<AnalyticsService>().getAnalyticsObserver(),
        ],
        home: StartUpView(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}

/// Feedback translation
class Translation implements FeedbackTranslation {
  @override
  String get submitButtonText => AppIntl.current?.submit ?? '';

  @override
  String get feedbackDescriptionText => AppIntl.current?.whatsWrong ?? '';

  @override
  String get draw => AppIntl.current?.draw ?? '';

  @override
  String get navigate => AppIntl.current?.navigate ?? '';
}

/// Get local storage path
Future<String> get _localPath async {
  final directory = await getExternalStorageDirectory();

  return directory.path.replaceFirst('/', '');
}

/// Create empty picture
Future<File> get _localFile async {
  final path = await _localPath;
  final now = DateTime.now();
  return File('$path/bugPicture-${now.hashCode}.png');
}
