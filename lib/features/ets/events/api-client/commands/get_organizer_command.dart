// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:notredame/features/ets/events/api-client/hello_api_client.dart';
import 'package:notredame/features/ets/events/api-client/models/organizer.dart';
import 'package:notredame/utils/api_response.dart';
import 'package:notredame/utils/command.dart';
import 'package:notredame/utils/http_exception.dart';

/// Call the Hello API to get the organizer
/// [organizerId] The organizer id
class GetOrganizerCommand implements Command<Organizer?> {
  final HelloAPIClient client;
  final http.Client _httpClient;
  final String organizerId;

  GetOrganizerCommand(this.client, this._httpClient, this.organizerId);

  @override
  Future<Organizer?> execute() async {
    if (client.apiLink == null || client.apiLink!.isEmpty) {
      throw ArgumentError("_apiLink is null or empty");
    }
    final uri = Uri.https(client.apiLink!, '/api/organizers/$organizerId');
    final response = await _httpClient.get(uri);

    // Log the http error and throw a exception
    if (response.statusCode != 200) {
      throw HttpException(
        message: response.body,
        prefix: HelloAPIClient.tagError,
        code: response.statusCode,
      );
    }

    final json = jsonDecode(response.body);
    return ApiResponse<Organizer>.fromJson(
            json as Map<String, dynamic>, Organizer.fromJson)
        .data;
  }
}
