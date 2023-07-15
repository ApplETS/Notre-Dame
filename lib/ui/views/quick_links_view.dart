// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEW-MODEL
import 'package:notredame/core/viewmodels/quick_links_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/web_link_card.dart';

// OTHER

class QuickLinksView extends StatefulWidget {
  @override
  _QuickLinksViewState createState() => _QuickLinksViewState();
}

class _QuickLinksViewState extends State<QuickLinksView>
    with SingleTickerProviderStateMixin {
  // Enable/Disable the edit state
  bool _editMode = false;

  // Animation Controller for Shake Animation
  AnimationController _controller;
  Animation<double> _animation;

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
        viewModelBuilder: () => QuickLinksViewModel(AppIntl.of(context)),
        builder: (context, model, child) => BaseScaffold(
          isLoading: model.isBusy,
          appBar: _buildAppBar(context, model),
          body: _buildBody(context, model),
        ),
      );

  AppBar _buildAppBar(BuildContext context, QuickLinksViewModel model) {
    return AppBar(
      title: Text(AppIntl.of(context).title_ets),
      automaticallyImplyLeading: false,
      actions: [if (_editMode) _buildQuickLinkAction(context, model)],
    );
  }

  IconButton _buildQuickLinkAction(
      BuildContext context, QuickLinksViewModel model) {
    return IconButton(
        icon: const Icon(Icons.restore),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return _buildRestoreDialog(context, model);
            },
          );
        });
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
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: _buildReorderableGridView(model),
          ),
        ),
      ),
    );
  }

  ReorderableGridView _buildReorderableGridView(QuickLinksViewModel model) {
    return ReorderableGridView.count(
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
      crossAxisCount: 3,
      children: List.generate(
        model.quickLinkList.length,
        (index) {
          return KeyedSubtree(
            key: ValueKey(model.quickLinkList[index].id),
            child: _buildGridChild(context, model, index),
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
      BuildContext context, QuickLinksViewModel model, int index) {
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
        builder: (BuildContext context, Widget child) {
          return Transform.rotate(
            angle: _editMode ? _animation.value : 0,
            child: child,
          );
        },
        child: Stack(
          children: [
            WebLinkCard(model.quickLinkList[index]),
            if (_editMode)
              Positioned(
                top: 0,
                left: 0,
                child: _buildDeleteButton(model, index),
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

  Widget _buildRestoreDialog(BuildContext context, QuickLinksViewModel model) {
    return AlertDialog(
      title: const Text('Restore QuickLinks'),
      content: SizedBox(
        width: double.maxFinite,
        child: model.deletedQuickLinks.isEmpty
            ? Text("No quick links to restore!")
            : ListView.builder(
                shrinkWrap: true,
                itemCount: model.deletedQuickLinks.length,
                itemBuilder: (context, index) {
                  final deletedQuickLink = model.deletedQuickLinks[index];
                  return ListTile(
                    title: Text(deletedQuickLink.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        model.restoreQuickLink(index);
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
