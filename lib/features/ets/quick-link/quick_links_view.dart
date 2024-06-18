// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/ets/quick-link/models/quick_link.dart';
import 'package:notredame/features/ets/quick-link/quick_links_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/app/widgets/web_link_card.dart';

class QuickLinksView extends StatefulWidget {
  @override
  _QuickLinksViewState createState() => _QuickLinksViewState();
}

class _QuickLinksViewState extends State<QuickLinksView>
    with SingleTickerProviderStateMixin {
  // Enable/Disable the edit state
  bool _editMode = false;

  // Animation Controller for Shake Animation
  late AnimationController _controller;
  late Animation<double> _animation;

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
        builder: (context, model, child) => BaseScaffold(
          isLoading: model.isBusy,
          appBar: _buildAppBar(context, model),
          body: _buildBody(context, model),
        ),
      );

  AppBar _buildAppBar(BuildContext context, QuickLinksViewModel model) {
    return AppBar(
      title: Text(AppIntl.of(context)!.title_ets),
      automaticallyImplyLeading: false,
      actions: const [],
    );
  }

  Widget _buildBody(BuildContext context, QuickLinksViewModel model) {
    return GestureDetector(
      onTap: () {
        if (_editMode) {
          _controller.reset();
          setState(() {
            _editMode = false;
          });
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: _buildReorderableGridView(
                    model, model.quickLinkList, _buildDeleteButton),
              ),
            ),
            if (_editMode && model.deletedQuickLinks.isNotEmpty) ...[
              const Divider(
                thickness: 2,
                indent: 10,
                endIndent: 10,
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  child: _buildReorderableGridView(
                      model, model.deletedQuickLinks, _buildAddButton),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  ReorderableGridView _buildReorderableGridView(
      QuickLinksViewModel model,
      List<QuickLink> quickLinks,
      Widget Function(QuickLinksViewModel, int) buildButtonFunction) {
    final double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;

    if (screenWidth > 310 && screenWidth < 440) {
      crossAxisCount = 3;
    } else {
      crossAxisCount =
          (screenWidth / 110).floor().clamp(1, double.infinity).toInt();
    }

    return ReorderableGridView.count(
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      crossAxisCount: crossAxisCount,
      children: List.generate(
        quickLinks.length,
        (index) {
          return KeyedSubtree(
            key: ValueKey(quickLinks[index].id),
            child:
                _buildGridChild(model, index, quickLinks, buildButtonFunction),
          );
        },
      ),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          model.reorderQuickLinks(oldIndex, newIndex);
        });
      },
    );
  }

  Widget _buildGridChild(
      QuickLinksViewModel model,
      int index,
      List<QuickLink> quickLinks,
      Widget Function(QuickLinksViewModel, int) buildButtonFunction) {
    return GestureDetector(
      onLongPress: _editMode
          ? null
          : () {
              _controller.repeat(reverse: true);
              setState(() {
                _editMode = true;
              });
            },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext context, Widget? child) {
          return Transform.rotate(
            angle: _editMode ? _animation.value : 0,
            child: child,
          );
        },
        child: Stack(
          children: [
            WebLinkCard(quickLinks[index]),
            if (_editMode &&
                quickLinks[index].id !=
                    1) // Don't show delete button for Security QuickLink
              Positioned(
                top: 0,
                left: 0,
                child: buildButtonFunction(model, index),
              ),
          ],
        ),
      ),
    );
  }

  Container _buildDeleteButton(QuickLinksViewModel model, int index) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppTheme.etsDarkGrey,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.close, color: Colors.white, size: 16),
        onPressed: () {
          setState(() {
            model.deleteQuickLink(index);
          });
        },
      ),
    );
  }

  Container _buildAddButton(QuickLinksViewModel model, int index) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        onPressed: () {
          setState(() {
            model.restoreQuickLink(index);
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
