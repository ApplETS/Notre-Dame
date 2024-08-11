// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';

// Project imports:
import 'package:notredame/features/ets/quick-link/widgets/security-info/widget/emergency_floating_button.dart';

class EmergencyView extends StatefulWidget {
  final String title;
  final String description;

  const EmergencyView(this.title, this.description);

  @override
  _EmergencyViewState createState() => _EmergencyViewState();
}

class _EmergencyViewState extends State<EmergencyView> {
  @override
  Widget build(BuildContext context) => BaseScaffold(
        appBar: AppBar(title: Text(widget.title)),
        showBottomBar: false,
        safeArea: false,
        fabPosition: FloatingActionButtonLocation.centerFloat,
        fab: emergencyFloatingButton(context),
        body: FutureBuilder<String>(
          future: rootBundle.loadString(widget.description),
          builder: (context, AsyncSnapshot<String> fileContent) {
            if (fileContent.hasData) {
              return SafeArea(
                  top: false,
                  bottom: false,
                  child: Scrollbar(
                    child: Markdown(
                        padding: const EdgeInsets.only(bottom: 120, top: 12, left: 12, right: 12),
                        data: fileContent.data!),
                  )
              );
            }
            // Loading a file is so fast showing a spinner would make the user experience worse
            return const SizedBox.shrink();
          }
      ));
}
