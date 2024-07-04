import 'package:flutter/material.dart';
import 'package:notredame/features/ets/quick-link/models/quick_link.dart';
import 'package:notredame/features/ets/quick-link/quick_links_viewmodel.dart';
import 'package:notredame/features/ets/quick-link/widgets/web_link_card.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

ReorderableGridView quickLinksReorderableGridView(
    QuickLinksViewModel model,
    List<QuickLink> quickLinks,
    BuildContext context,
    Function(Function()) setState,
    AnimationController controller,
    Animation<double> animation,
    bool deleteButton) {
  final double screenWidth = MediaQuery.of(context).size.width;
  int crossAxisCount;

  if (screenWidth > 310 && screenWidth < 440) {
    crossAxisCount = 3;
  } else {
    crossAxisCount =
        (screenWidth / 110).floor().clamp(1, double.infinity).toInt();
  }

  return ReorderableGridView.count(
    padding: EdgeInsets.zero,
    mainAxisSpacing: 2.0,
    crossAxisSpacing: 2.0,
    crossAxisCount: crossAxisCount,
    children: List.generate(
      quickLinks.length,
      (index) {
        return KeyedSubtree(
          key: ValueKey(quickLinks[index].id),
          child: _buildGridChild(
              model,
              index,
              quickLinks,
              controller,
              animation,
              setState,
              deleteButton ? _buildDeleteButton : _buildAddButton),
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
    AnimationController controller,
    Animation<double> animation,
    Function(Function()) setState,
    Widget Function(QuickLinksViewModel, int, Function(Function()))
        buildButtonFunction) {
  return GestureDetector(
    onLongPress: model.editMode
        ? null
        : () {
            controller.repeat(reverse: true);
            setState(() {
              model.editMode = true;
            });
          },
    child: AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.rotate(
          angle: model.editMode ? animation.value : 0,
          child: child,
        );
      },
      child: Stack(
        children: [
          WebLinkCard(quickLinks[index]),
          if (model.editMode &&
              quickLinks[index].id !=
                  1) // Don't show delete button for Security QuickLink
            Positioned(
              top: 0,
              left: 0,
              child: buildButtonFunction(model, index, setState),
            ),
        ],
      ),
    ),
  );
}

Container _buildDeleteButton(
    QuickLinksViewModel model, int index, Function(Function()) setState) {
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

Container _buildAddButton(
    QuickLinksViewModel model, int index, Function(Function()) setState) {
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
