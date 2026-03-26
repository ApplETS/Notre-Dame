// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/ui/core/ui/modal_bottom_sheet_header.dart';

class ModalBottomSheetLayout extends StatelessWidget {
  final Widget title;
  final Widget body;
  final EdgeInsetsGeometry bodyPadding;
  final bool applyBottomSafeArea;

  const ModalBottomSheetLayout({
    super.key,
    required this.title,
    required this.body,
    this.bodyPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
    this.applyBottomSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModalBottomSheetHeader(title: title),
          SafeArea(
            left: false,
            right: false,
            bottom: applyBottomSafeArea,
            child: Padding(padding: bodyPadding, child: body),
          ),
        ],
      ),
    );
  }
}
