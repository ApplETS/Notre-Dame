import 'dart:ui';

import 'package:notredame/features/app/widgets/broadcast_card/broadcast_card.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:notredame/features/app/analytics/remote_config_service.dart';
import 'package:notredame/features/app/integration/launch_url_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/utils/locator.dart';

class BroadcastCardViewmodel extends FutureViewModel<BroadcastCard> {
  final remoteConfigService = locator<RemoteConfigService>();
  final AppIntl _appIntl;
  BroadcastCard? card;

  BroadcastCardViewmodel(this._appIntl);

  Future<void> launchBroadcastUrl(String url) async {
    final LaunchUrlService launchUrlService = locator<LaunchUrlService>();
    final NavigationService navigationService = locator<NavigationService>();
    try {
      await launchUrlService.launchInBrowser(url, Brightness.light);
    } catch (error) {
      // An exception is thrown if browser app is not installed on Android device.
      await navigationService.pushNamed(RouterPaths.webView, arguments: url);
    }
  }

  @override
  Future<BroadcastCard> futureToRun() async {
    String? message;
    String? title;

    if (_appIntl.localeName == "fr") {
      message = await remoteConfigService.dashboardMessageFr;
      title = await remoteConfigService.dashboardMessageTitleFr;
    } else {
      message = await remoteConfigService.dashboardMessageEn;
      title = await remoteConfigService.dashboardMessageTitleEn;
    }
    final color = Color(int.parse(await remoteConfigService.dashboardMsgColor));
    final url = await remoteConfigService.dashboardMsgUrl;
    final type = await remoteConfigService.dashboardMsgType;

    return BroadcastCard(title, message, url, type, color);
  }
}
