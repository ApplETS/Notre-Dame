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
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          children: List.generate(quickLinks.length,
              (index) => QuickLinksWidget(quickLinks[index])),
        ),
      ),
    );
  }
}
