// widgets/LanguageListViewWidget.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/features/more/settings/choose_language_viewmodel.dart';
import 'package:notredame/features/more/settings/widget/language_card_widget.dart';

class LanguageListViewWidget extends StatelessWidget {
  final ChooseLanguageViewModel model;

  const LanguageListViewWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: model.languages.length,
      itemBuilder: (BuildContext context, int index) {
        return LanguageCardWidget(
          language: model.languages[index],
          isSelected: model.languageSelectedIndex == index,
          onTap: () => model.changeLanguage(index),
        );
      },
    );
  }
}
