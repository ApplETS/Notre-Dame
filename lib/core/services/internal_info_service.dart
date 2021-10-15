// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

// UTILS
import 'package:notredame/locator.dart';

// SERVICES
import 'package:notredame/core/services/networking_service.dart';

class InternalInfoService {
  // Build the error message with the current device informations
  Future<String> getDeviceInfoForErrorReporting() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final NetworkingService _networkingService = locator<NetworkingService>();
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceName;

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName = androidInfo.model;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceName = iosInfo.utsname.machine;
    }

    return "**Device Infos** \n"
        "- **Device:** $deviceName \n"
        "- **Version:** ${packageInfo.version} \n"
        "- **Connectivity:** ${await _networkingService.getConnectionType()} \n"
        "- **Build number:** ${packageInfo.buildNumber} \n"
        "- **Platform operating system:** ${Platform.operatingSystem} \n"
        "- **Platform operating system version:** ${Platform.operatingSystemVersion} \n";
  }
}
