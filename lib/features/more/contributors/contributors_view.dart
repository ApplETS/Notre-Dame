// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:github/github.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/more/contributors/contributors_viewmodel.dart';
import 'package:notredame/features/more/contributors/widgets/contributor_title_widget.dart';
import 'package:notredame/utils/utils.dart';

class ContributorsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<ContributorsViewModel>.reactive(
        viewModelBuilder: () => ContributorsViewModel(),
        builder: (context, model, child) {
          return BaseScaffold(
            safeArea: false,
            appBar: AppBar(
              title: Text(AppIntl.of(context)!.more_contributors),
            ),
            showBottomBar: false,
            body: FutureBuilder<List<Contributor>>(
              future: model.contributors,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => ContributorTileWidget(
                    contributor: snapshot.data![index],
                  ),
                );
              },
            ),
          );
        },
      );

  Widget contributorsList(List<Contributor> contributors) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: contributors.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(contributors[index].login ?? ''),
        leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(contributors[index].avatarUrl ?? '')),
        onTap: () => Utils.launchURL(
            contributors[index].htmlUrl ?? '', AppIntl.of(context)!),
      ),
    );
  }
}
