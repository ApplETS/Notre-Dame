// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:github/github.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/more/contributors/view_model/contributors_viewmodel.dart';

class ContributorsView extends StatelessWidget {
  ContributorsView({super.key});
  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();

  @override
  Widget build(BuildContext context) => ViewModelBuilder<ContributorsViewModel>.reactive(
    viewModelBuilder: () => ContributorsViewModel(),
    builder: (context, model, child) {
      return BaseScaffold(
        appBar: AppBar(title: Text(AppIntl.of(context)!.more_contributors)),
        body: FutureBuilder<List<Contributor>>(
          future: model.contributors,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // Populate the skeleton
              final fakeContributors = List.filled(30, Contributor(login: "Username"));
              return Skeletonizer(child: contributorsList(fakeContributors));
            } else {
              return contributorsList(snapshot.data!);
            }
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
          backgroundImage: NetworkImage(contributors[index].avatarUrl ?? ''),
        ),
        onTap: () => _launchUrlService.launchInBrowser(contributors[index].htmlUrl ?? ''),
      ),
    );
  }
}
