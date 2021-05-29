// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:package_info/package_info.dart';

// UTILS
import 'package:notredame/locator.dart';

// SERVICES
import 'package:notredame/core/services/networking_service.dart';

class InternalInfoService {
  
  // Build the error message with the current device informations
  Future<String> getDeviceInfoForErrorReporting() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final NetworkingService _networkingService = locator<NetworkingService>();
    
    return "**Device Infos** \n"
            "- **Version:** ${packageInfo.version} \n"
            "- **Connectivity:** ${await _networkingService.getConnectionType()} \n"
            "- **Build number:** ${packageInfo.buildNumber} \n"
            "- **Platform operating system:** ${Platform.operatingSystem} \n"
            "- **Platform operating system version:** ${Platform.operatingSystemVersion} \n";
  }
}
