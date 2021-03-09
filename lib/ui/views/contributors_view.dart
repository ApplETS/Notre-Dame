// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/contributors_viewmodel.dart';

// OTHERS
import 'package:notredame/ui/utils/loading.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/core/utils/utils.dart';

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
            body: FutureBuilder<List<Contributor>>(
              future: model.contributors,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return buildLoading();
                }
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(snapshot.data[index].login),
                    leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(snapshot.data[index].avatarUrl)),
                    onTap: () => Utils.launchURL(snapshot.data[index].htmlUrl, AppIntl.of(context)),
                  ),
                );
              },
            ),
          );
        },
      );
}
