// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/core/models/quick_link.dart';
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

class _QuickLinksViewState extends State<QuickLinksView> {
  // Enable/Disable the edit state
  bool _editMode = false;

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<QuickLinksViewModel>.reactive(
        viewModelBuilder: () => QuickLinksViewModel(AppIntl.of(context)),
        builder: (context, model, child) => BaseScaffold(
          isLoading: model.isBusy,
          appBar: AppBar(
            title: Text(AppIntl.of(context).title_ets),
            automaticallyImplyLeading: false,
          ),
          body: GestureDetector(
            onTap: () {
              setState(() {
                _editMode = false;
              });
            },
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ReorderableGridView.count(
                    mainAxisSpacing: 2.0,
                    crossAxisSpacing: 2.0,
                    crossAxisCount: 3,
                    children: List.generate(
                      model.quickLinkList.length,
                      (index) {
                        return KeyedSubtree(
                          key: ValueKey(model.quickLinkList[index].id),
                          child: GestureDetector(
                            onLongPress: _editMode
                                ? null
                                : () {
                                    setState(() {
                                      _editMode = true;
                                    });
                                  },
                            child: Stack(
                              children: [
                                WebLinkCard(model.quickLinkList[index]),
                                if (_editMode)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.close,
                                            color: Colors.white, size: 16),
                                        onPressed: () {
                                          setState(() {
                                            model.quickLinkList.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final QuickLink item =
                            model.quickLinkList.removeAt(oldIndex);
                        model.quickLinkList.insert(newIndex, item);
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
