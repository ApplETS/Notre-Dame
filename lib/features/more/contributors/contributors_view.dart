// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:github/github.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/utils/utils.dart';
import 'package:notredame/features/more/contributors/contributors_viewmodel.dart';
import 'package:notredame/utils/loading.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';

class ContributorsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<ContributorsViewModel>.reactive(
        viewModelBuilder: () => ContributorsViewModel(),
        builder: (context, model, child) {
          return BaseScaffold(
            appBar: AppBar(
              title: Text(AppIntl.of(context)!.more_contributors),
            ),
            showBottomBar: false,
            body: FutureBuilder<List<Contributor>>(
              future: model.contributors,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return buildLoading();
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(snapshot.data![index].login ?? ''),
                    leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            snapshot.data![index].avatarUrl ?? '')),
                    onTap: () => Utils.launchURL(
                        snapshot.data![index].htmlUrl ?? '',
                        AppIntl.of(context)),
                  ),
                );
              },
            ),
          );
        },
      );
}
