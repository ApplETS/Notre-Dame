import 'package:notredame/features/ets/events/api-client/hello_api_client.dart';
import 'package:notredame/features/ets/events/api-client/models/organizer.dart';

// Project imports:

import 'package:notredame/utils/locator.dart';

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
