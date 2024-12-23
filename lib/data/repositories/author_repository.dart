// Project imports:
import 'package:notredame/data/services/hello/hello_service.dart';
import 'package:notredame/data/models/hello/organizer.dart';
import 'package:notredame/locator.dart';

/// Repository to access authors
class AuthorRepository {
  static const String tag = "AuthorRepository";

  final HelloService _helloApiClient = locator<HelloService>();

  /// Get the organizer by id.
  Future<Organizer?> getOrganizer(String organizerId) async {
    final Organizer? organizer =
        await _helloApiClient.getOrganizer(organizerId);
    return organizer;
  }
}
