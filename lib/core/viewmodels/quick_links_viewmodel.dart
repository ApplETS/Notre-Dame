import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickLinks {
  String image;
  String name;
  String link;
  QuickLinks({@required this.image, @required this.name, this.link});
}

Future<void> makePhoneCall(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
