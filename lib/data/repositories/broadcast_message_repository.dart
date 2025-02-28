// Dart imports:
import 'dart:ui';

// Project imports:
import 'package:notredame/data/models/broadcast_message.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/domain/broadcast_icon_type.dart';
import 'package:notredame/locator.dart';

class BroadcastMessageRepository {
  final RemoteConfigService _remoteConfigService =
      locator<RemoteConfigService>();

  BroadcastMessage getBroadcastMessage(String localeName) {
    final iconType = BroadcastIconType.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            _remoteConfigService.dashboardMsgType.toLowerCase(),
        orElse: () => BroadcastIconType.other);

    return BroadcastMessage(
        message: localeName == "fr"
            ? _remoteConfigService.dashboardMessageFr
            : _remoteConfigService.dashboardMessageEn,
        title: localeName == "fr"
            ? _remoteConfigService.dashboardMessageTitleFr
            : _remoteConfigService.dashboardMessageTitleEn,
        color: Color(int.parse(_remoteConfigService.dashboardMsgColor)),
        url: _remoteConfigService.dashboardMsgUrl,
        type: iconType);
  }
}
