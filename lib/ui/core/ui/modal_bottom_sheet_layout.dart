// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_theme.dart';

class ModalBottomSheetLayout extends StatelessWidget {
  final Widget title;
  final Widget body;
  final EdgeInsetsGeometry bodyPadding;

  const ModalBottomSheetLayout({
    super.key,
    required this.title,
    required this.body,
    this.bodyPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
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
          Container(
            decoration: BoxDecoration(color: context.theme.appColors.modalTitle),
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      height: 5,
                      width: 50,
                      decoration: BoxDecoration(
                        color: context.theme.appColors.modalHandle,
                        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: title),
              ],
            ),
          ),
          SafeArea(
            left: false,
            right: false,
            child: Padding(padding: bodyPadding, child: body),
          ),
        ],
      ),
    );
  }
}
