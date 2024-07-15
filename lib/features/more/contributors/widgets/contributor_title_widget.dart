// widgets/ContributorTileWidget.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:github/github.dart';

// Project imports:
import 'package:notredame/utils/utils.dart';

class ContributorTileWidget extends StatelessWidget {
  final Contributor contributor;

  const ContributorTileWidget({super.key, required this.contributor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(contributor.login ?? ''),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(contributor.avatarUrl ?? ''),
      ),
      onTap: () => Utils.launchURL(
        contributor.htmlUrl ?? '',
        AppIntl.of(context)!,
      ),
    );
  }
}
