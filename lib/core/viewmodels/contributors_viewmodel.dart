// FLUTTER / DART / THIRD-PARTIES
import 'package:github/github.dart';
import 'package:oktoast/oktoast.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

// OTHER
import 'package:notredame/generated/l10n.dart';

class ContributorsViewModel extends FutureViewModel {
  /// Create a GitHub Client, with anonymous authentication by default
  GitHub github = GitHub();

  Future<List<Contributor>> get contributors => _contributors;

  /// List of contributors
  Future<List<Contributor>> _contributors;

  /// Used to open a url
  Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showToast(AppIntl.current.error);
      throw 'Could not launch $url';
    }
  }

  @override
  Future futureToRun() {
    return _contributors = github.repositories
        .listContributors(
          RepositorySlug.full("ApplETS/Notre-Dame"),
        )
        .toList();
  }
}
