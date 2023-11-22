// Dart imports:
import 'dart:io';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/locator.dart';

// UTILS

// SERVICES

class InternalInfoService {
  // Build the error message with the current device informations
  Future<String> getDeviceInfoForErrorReporting() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final NetworkingService networkingService = locator<NetworkingService>();
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? deviceName;

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName = androidInfo.model;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceName = iosInfo.utsname.machine;
    }

    return "**Device Infos** \n"
        "- **Device:** ${deviceName ?? 'Not Provided'} \n"
        "- **Version:** ${packageInfo.version} \n"
        "- **Connectivity:** ${await networkingService.getConnectionType()} \n"
        "- **Build number:** ${packageInfo.buildNumber} \n"
        "- **Platform operating system:** ${Platform.operatingSystem} \n"
        "- **Platform operating system version:** ${Platform.operatingSystemVersion} \n";
  }

  /// Get the current device informations to show for error reporting
  Future<PackageInfo> getPackageInfo() async {
    return PackageInfo.fromPlatform();
  }
}
