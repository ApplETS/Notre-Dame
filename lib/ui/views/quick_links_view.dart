import 'package:flutter/material.dart';
import 'package:notredame/core/constants/quick_links.dart';
import 'package:notredame/ui/widgets/quick_links.dart';

class QuickLinksView extends StatefulWidget {
  @override
  _QuickLinksViewState createState() => _QuickLinksViewState();
}

class _QuickLinksViewState extends State<QuickLinksView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ETS'),
      ),
      body: Align(
        alignment: const Alignment(0.0, -0.9),
        child: SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: List.generate(quickLinks.length,
                (index) => QuickLinksWidget(quickLinks[index])),
          ),
        ),
      ),
    );
  }
}
