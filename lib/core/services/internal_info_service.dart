// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:package_info/package_info.dart';

class InternalInfoService {
  // Build the error message with the current device informations
  Future<String> getDeviceInfoForErrorReporting() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return "**Device Infos** \n"
        "- **Version:** ${packageInfo.version} \n"
        "- **Build number:** ${packageInfo.buildNumber} \n"
        "- **Platform operating system:** ${Platform.operatingSystem} \n"
        "- **Platform operating system version:** ${Platform.operatingSystemVersion} \n";
  }
}
