// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

// Project imports:
import 'package:notredame/features/ets/events/api-client/hello_api_client.dart';
import 'package:notredame/features/ets/events/api-client/models/activity_area.dart';
import 'package:notredame/features/ets/events/api-client/models/news.dart';
import 'package:notredame/features/ets/events/api-client/models/organizer.dart';
import 'package:notredame/features/ets/events/api-client/models/paginated_news.dart';
import 'package:notredame/features/ets/events/api-client/models/report.dart';
import 'package:notredame/utils/api_response.dart';
import 'package:notredame/utils/http_exception.dart';
import '../../../app/signets_api/http_client_mock_helper.dart';

void main() {
  const String helloNewsAPI = "api.hello.ca";
  late HelloAPIClient service;
  late MockClient mockClient;

  group('HelloApi - ', () {
    setUp(() {
      // default response stub
      mockClient = MockClient((request) => Future.value(Response("", 200)));

      service = HelloAPIClient(client: mockClient);
      service.apiLink = helloNewsAPI;
    });

    tearDown(() {
      mockClient.close();
    });

    group('getEvents - ', () {
      test('empty data', () async {
        final query = {
          'pageNumber': 1.toString(),
          'pageSize': 10.toString(),
        };
        final uri = Uri.https(helloNewsAPI, '/api/events', query);
        mockClient = HttpClientMockHelper.stubJsonGet(uri.toString(), {
          'data': [],
          'pageNumber': 1,
          'pageSize': 10,
          'totalPages': 1,
          'totalRecords': 0
        });
        service = buildService(mockClient);

        final result = await service.getEvents();

        expect(result, isA<PaginatedNews>());
        expect(result.news.length, 0);
      });

      test('one news', () async {
        final news = News(
            id: "402e711c-0f72-4aab-9684-31f1956c1da1",
            title: "title",
            content: "content",
            imageUrl: "imageUrl",
            state: "1",
            publicationDate: DateTime.now(),
            eventStartDate: DateTime.now().add(const Duration(days: 4)),
            eventEndDate: DateTime.now().add(const Duration(days: 4, hours: 2)),
            createdAt: DateTime.now().subtract(const Duration(days: 4)),
            updatedAt: DateTime.now().subtract(const Duration(days: 4)),
            tags: [],
            organizer: Organizer(
              id: "3a5cb049-67cf-428e-b98f-ef29fb633e0d",
              organization: "name2",
              email: "email2",
              type: "organizer",
              activityArea: ActivityArea(
                  id: "1",
                  nameFr: "Fr",
                  nameEn: "En",
                  createdAt: DateTime.now().subtract(const Duration(days: 4)),
                  updatedAt: DateTime.now().subtract(const Duration(days: 4))),
            ));

        final query = {
          'pageNumber': 1.toString(),
          'pageSize': 10.toString(),
        };
        final uri = Uri.https(helloNewsAPI, '/api/events', query);
        mockClient = HttpClientMockHelper.stubJsonGet(uri.toString(), {
          'data': [news],
          'pageNumber': 1,
          'pageSize': 10,
          'totalPages': 1,
          'totalRecords': 1
        });
        service = buildService(mockClient);

        final result = await service.getEvents();

        expect(result, isA<PaginatedNews>());
        expect(result.news.length, 1);
        expect(result.news[0].id, "402e711c-0f72-4aab-9684-31f1956c1da1");
      });

      test('any other errors for now', () async {
        const int statusCode = 500;
        const String message = "An error has occurred.";

        mockClient = HttpClientMockHelper.stubJsonPost(
            helloNewsAPI, {"Message": message}, statusCode);
        service = buildService(mockClient);

        expect(service.getEvents(), throwsA(isA<HttpException>()));
      });
    });
  });

  group('getOrganizer - ', () {
    test('successful response', () async {
      const organizerId = '1234';
      final organizer = Organizer(
        id: organizerId,
        name: 'Test Organizer',
        email: 'test@example.com',
        avatarUrl: 'https://example.com/avatar.png',
        type: 'type',
        organization: 'Test Organization',
        activityArea: ActivityArea(
            id: "1",
            nameFr: "Fr",
            nameEn: "En",
            createdAt: DateTime.now().subtract(const Duration(days: 4)),
            updatedAt: DateTime.now().subtract(const Duration(days: 4))),
        isActive: true,
        profileDescription: 'Test Description',
        facebookLink: 'https://facebook.com/test',
        instagramLink: 'https://instagram.com/test',
        tikTokLink: 'https://tiktok.com/test',
        xLink: 'https://x.com/test',
        discordLink: 'https://discord.com/test',
        linkedInLink: 'https://linkedin.com/test',
        redditLink: 'https://reddit.com/test',
        webSiteLink: 'https://example.com',
      );

      final apiResponse = ApiResponse<Organizer>(data: organizer);

      final uri = Uri.https(helloNewsAPI, '/api/organizers/$organizerId');
      mockClient = HttpClientMockHelper.stubJsonGet(uri.toString(),
          apiResponse.toJson((organizer) => organizer.toJson()));
      service = buildService(mockClient);

      final result = await service.getOrganizer(organizerId);

      expect(result, isA<Organizer>());
      expect(result?.id, organizerId);
      expect(result?.name, 'Test Organizer');
    });

    test('error response', () async {
      const organizerId = '1234';
      const int statusCode = 404;
      const String message = "Organizer not found.";

      final uri =
          Uri.https(helloNewsAPI, '/api/moderator/organizer/$organizerId');
      mockClient = HttpClientMockHelper.stubJsonGet(
          uri.toString(), {"Message": message}, statusCode);
      service = buildService(mockClient);

      expect(service.getOrganizer(organizerId), throwsA(isA<HttpException>()));
    });
  });

  final report = Report(reason: "Test reason", category: "1");

  group('reportNews - ', () {
    test('successful report', () async {
      const newsId = '123';
      final uri = Uri.https(helloNewsAPI, '/api/reports/$newsId');
      mockClient = HttpClientMockHelper.stubJsonPost(uri.toString(), {});
      service = buildService(mockClient);

      final result = await service.reportNews(newsId, report);

      expect(result, isTrue);
    });

    test('error response', () async {
      const newsId = '123';
      const int statusCode = 400;
      const String message = "Error reporting news.";

      final uri = Uri.https(helloNewsAPI, '/api/events/$newsId/reports');
      mockClient = HttpClientMockHelper.stubJsonPost(
          uri.toString(), {"Message": message}, statusCode);
      service = buildService(mockClient);

      expect(service.reportNews(newsId, report), throwsA(isA<HttpException>()));
    });
  });
}

HelloAPIClient buildService(MockClient client) {
  final apiClient = HelloAPIClient(client: client);
  apiClient.apiLink = "api.hello.ca";
  return apiClient;
}
