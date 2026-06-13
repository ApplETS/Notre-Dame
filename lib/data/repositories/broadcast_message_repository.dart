// Dart imports:
import 'dart:ui';

// Project imports:
import 'package:notredame/data/models/broadcast_message.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

class BroadcastMessageRepository {
  final RemoteConfigService _remoteConfigService = locator<RemoteConfigService>();

  BroadcastMessage getBroadcastMessage(String localeName) {
    final parsedColor = int.tryParse(_remoteConfigService.dashboardMsgColor);

    return BroadcastMessage(
      message: localeName == "fr" ? _remoteConfigService.dashboardMessageFr : _remoteConfigService.dashboardMessageEn,
      color: Color(parsedColor ?? AppPalette.etsLightRed.toARGB32()),
      url: _remoteConfigService.dashboardMsgUrl,
    );
  }
}
