// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/constants/quick_links.dart';
import 'package:notredame/core/managers/quick_link_repository.dart';
import 'package:notredame/core/models/quick_link.dart';
import 'package:notredame/core/models/quick_link_data.dart';
import 'package:notredame/core/viewmodels/quick_links_viewmodel.dart';
import '../helpers.dart';
import '../mock/managers/quick_links_repository_mock.dart';

void main() {
  late AppIntl intl;
  late QuickLinksViewModel viewModel;
  late QuickLinkRepository quickLinkRepository;

  // Sample data for tests
  late QuickLinkData quickLinkDataSample;
  late QuickLink quickLinkSample;

  group("QuickLinksViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      quickLinkRepository = setupQuickLinkRepositoryMock();
      intl = await setupAppIntl();

      viewModel = QuickLinksViewModel(intl);
      quickLinkDataSample = QuickLinkData(id: 1, index: 0);
      quickLinkSample = quickLinks(intl).first;
    });

    tearDown(() {
      unregister<QuickLinkRepository>();
    });

    group('getQuickLinks -', () {
      test('Should get quick links from cache', () async {
        QuickLinkRepositoryMock.stubGetQuickLinkDataFromCache(
            quickLinkRepository as QuickLinkRepositoryMock,
            toReturn: [quickLinkDataSample]);

        QuickLinkRepositoryMock.stubGetDefaultQuickLinks(
            quickLinkRepository as QuickLinkRepositoryMock,
            toReturn: [quickLinkSample]);

        final result = await viewModel.getQuickLinks();

        expect(result, [quickLinkSample]);
      });

      test('Should return default quick links if cache is not initialized',
          () async {
        QuickLinkRepositoryMock.stubGetQuickLinkDataFromCacheException(
            quickLinkRepository as QuickLinkRepositoryMock);

        QuickLinkRepositoryMock.stubGetDefaultQuickLinks(
            quickLinkRepository as QuickLinkRepositoryMock,
            toReturn: [quickLinkSample]);

        final result = await viewModel.getQuickLinks();

        expect(result, [quickLinkSample]);
      });
    });

    group('deleteQuickLink -', () {
      test('Should delete a quick link and update cache', () async {
        viewModel.quickLinkList = [quickLinkSample];

        await viewModel.deleteQuickLink(0);

        expect(viewModel.quickLinkList, isEmpty);
        expect(viewModel.deletedQuickLinks, [quickLinkSample]);
      });
    });

    group('restoreQuickLink -', () {
      test('Should restore a deleted quick link and update cache', () async {
        viewModel.deletedQuickLinks = [quickLinkSample];

        await viewModel.restoreQuickLink(0);

        expect(viewModel.deletedQuickLinks, isEmpty);
        expect(viewModel.quickLinkList, [quickLinkSample]);
      });
    });

    group('reorderQuickLinks -', () {
      test('Should reorder quick links and update cache', () async {
        final anotherQuickLink = quickLinks(intl).last;
        viewModel.quickLinkList = [quickLinkSample, anotherQuickLink];

        await viewModel.reorderQuickLinks(0, 1);

        expect(viewModel.quickLinkList, [anotherQuickLink, quickLinkSample]);
      });
    });

    group('futureToRun -', () {
      test('Should fetch and set quick links', () async {
        QuickLinkRepositoryMock.stubGetQuickLinkDataFromCache(
            quickLinkRepository as QuickLinkRepositoryMock,
            toReturn: [quickLinkDataSample]);

        QuickLinkRepositoryMock.stubGetDefaultQuickLinks(
            quickLinkRepository as QuickLinkRepositoryMock,
            toReturn: [quickLinkSample]);

        final result = await viewModel.futureToRun();

        expect(result, [quickLinkSample]);
      });
    });
  });
}
