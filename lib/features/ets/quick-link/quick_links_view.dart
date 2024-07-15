// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/ets/quick-link/quick_links_viewmodel.dart';
import 'package:notredame/features/ets/quick-link/widgets/quick_links_reorderable.dart';

class QuickLinksView extends StatefulWidget {
  @override
  _QuickLinksViewState createState() => _QuickLinksViewState();
}

class _QuickLinksViewState extends State<QuickLinksView>
    with SingleTickerProviderStateMixin {
  // Animation Controller for Shake Animation
  late AnimationController _controller;
  late Animation<double> _animation;

  void refresh(Function() function) {
    setState(() {
      function();
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _animation = Tween<double>(begin: -0.05, end: 0.05).animate(_controller);
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<QuickLinksViewModel>.reactive(
        viewModelBuilder: () => QuickLinksViewModel(AppIntl.of(context)!),
        builder: (context, model, child) => Scaffold(
          body: _buildBody(context, model),
        ),
      );

  Widget _buildBody(BuildContext context, QuickLinksViewModel model) {
    return GestureDetector(
      onTap: () {
        if (model.editMode) {
          _controller.reset();
          setState(() {
            model.editMode = false;
          });
        }
      },
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: quickLinksReorderableGridView(model, model.quickLinkList,
                  context, refresh, _controller, _animation, true),
            ),
          ),
          if (model.editMode && model.deletedQuickLinks.isNotEmpty) ...[
            const Divider(
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: quickLinksReorderableGridView(
                    model,
                    model.deletedQuickLinks,
                    context,
                    refresh,
                    _controller,
                    _animation,
                    false),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
