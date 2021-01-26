// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/contributors_viewmodel.dart';

// OTHERS
import 'package:notredame/ui/utils/loading.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/generated/l10n.dart';

class ContributorsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<ContributorsViewModel>.reactive(
        viewModelBuilder: () => ContributorsViewModel(),
        builder: (context, model, child) {
          return BaseScaffold(
            appBar: AppBar(
              title: Text(AppIntl.of(context).more_contributors),
            ),
            showBottomBar: false,
            body: FutureBuilder(
              future: model.contributors,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return buildLoading();
                }
                return ListView.builder(
                  itemCount: snapshot.data.length as int,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(snapshot.data[index].login as String),
                    leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            snapshot.data[index].avatarUrl as String)),
                    onTap: () =>
                        model.launchURL(snapshot.data[index].htmlUrl as String),
                  ),
                );
              },
            ),
          );
        },
      );
}
