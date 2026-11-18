// Flutter imports:
import 'package:material_ui/material_ui.dart';

Widget buildLoading({bool isInteractionLimitedWhileLoading = true}) => Stack(
  children: [
    if (isInteractionLimitedWhileLoading)
      const Opacity(opacity: 0.3, child: ModalBarrier(dismissible: false, color: Colors.transparent)),
    const Center(child: CircularProgressIndicator()),
  ],
);
