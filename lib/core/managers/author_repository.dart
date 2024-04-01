// Flutter imports:
import 'package:ets_api_clients/clients.dart';

// Package imports:
import 'package:ets_api_clients/models.dart';

// Project imports:
import 'package:notredame/locator.dart';

/// Repository to access authors
class AuthorRepository {
  static const String tag = "AuthorRepository";

  final HelloAPIClient _helloApiClient = locator<HelloAPIClient>();

  /// Get the organizer by id.
  Future<Organizer?> getOrganizer(String organizerId) async {
    final Organizer? organizer =
        await _helloApiClient.getOrganizer(organizerId);
    return organizer;
  }
}
