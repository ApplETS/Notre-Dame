// Package imports:
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

class LaunchUrlService {
  final SettingsRepository settingsManager = locator<SettingsRepository>();

  Future<void> writeEmail(String emailAddress, String subject) async {
    final uri = Uri.parse('mailto:$emailAddress?subject=$subject');
    if (await canLaunchUrl(uri)) {
      launchUrl(uri);
    } else {
      throw 'Could not send email to $emailAddress';
    }
  }

  Future<void> call(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      launchUrl(uri);
    } else {
      throw 'Could not call $phoneNumber';
    }
  }

  Future<void> launchInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, browserConfiguration: BrowserConfiguration(showTitle: false));
    } else {
      throw 'Could not launch $url';
    }
  }
}
