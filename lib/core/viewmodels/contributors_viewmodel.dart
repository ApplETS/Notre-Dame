// FLUTTER / DART / THIRD-PARTIES
import 'package:github/github.dart';
import 'package:stacked/stacked.dart';

class ContributorsViewModel extends FutureViewModel {
  /// Create a GitHub Client, with anonymous authentication by default
  GitHub github = GitHub();

  Future<List<Contributor>> get contributors => _contributors;

  /// List of contributors
  Future<List<Contributor>> _contributors;

  @override
  Future futureToRun() {
    return _contributors = github.repositories
        .listContributors(
          RepositorySlug.full("ApplETS/Notre-Dame"),
        )
        .where((cont) => cont.id != 49699333) // Remove dependabot
        .toList();
  }










  
}
