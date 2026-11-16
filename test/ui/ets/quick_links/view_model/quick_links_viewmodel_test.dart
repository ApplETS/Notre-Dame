// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/models/quick_link.dart';
import 'package:notredame/data/models/quick_link_data.dart';
import 'package:notredame/data/models/quick_links.dart';
import 'package:notredame/data/repositories/quick_link_repository.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/ets/quick_links/view_model/quick_links_viewmodel.dart';
import '../../../../data/mocks/repositories/quick_links_repository_mock.dart';
import '../../../../helpers.dart';

void main() {
  late QuickLinkRepositoryMock quickLinkRepositoryMock;

  late QuickLinksViewModel viewModel;

  // Sample data for tests
  late AppIntl intl;
  late QuickLinkData quickLinkDataSample;
  late QuickLink quickLinkSample;

  group("QuickLinksViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      quickLinkRepositoryMock = setupQuickLinkRepositoryMock();
      intl = await setupAppIntl();

      viewModel = QuickLinksViewModel(intl);
      quickLinkDataSample = QuickLinkData(id: 1, index: 0);
      quickLinkSample = quickLinks(intl).first;
    });

    tearDown(() {
      unregister<QuickLinkRepository>();
    });

    group('getUserQuickLinks -', () {
      test('Should apply the saved order on the available links', () async {
        final anotherQuickLink = quickLinks(intl).last;
        QuickLinkRepositoryMock.stubGetQuickLinks(
          quickLinkRepositoryMock,
          toReturn: [quickLinkSample, anotherQuickLink],
        );
        QuickLinkRepositoryMock.stubGetQuickLinkDataFromCache(
          quickLinkRepositoryMock,
          toReturn: [
            QuickLinkData(id: anotherQuickLink.id, index: 0),
            QuickLinkData(id: quickLinkSample.id, index: 1),
          ],
        );
        QuickLinkRepositoryMock.stubGetHiddenQuickLinkIdsFromCache(quickLinkRepositoryMock);
        QuickLinkRepositoryMock.stubGetDefaultQuickLinks(quickLinkRepositoryMock, toReturn: quickLinks(intl));

        final result = await viewModel.getUserQuickLinks();

        expect(result.visible, [anotherQuickLink, quickLinkSample]);
        expect(result.hidden, isEmpty);
      });

      test('Should return the available links if the user never customized them', () async {
        QuickLinkRepositoryMock.stubGetQuickLinks(quickLinkRepositoryMock, toReturn: [quickLinkSample]);
        QuickLinkRepositoryMock.stubGetQuickLinkDataFromCacheException(quickLinkRepositoryMock);
        QuickLinkRepositoryMock.stubGetHiddenQuickLinkIdsFromCacheException(quickLinkRepositoryMock);
        QuickLinkRepositoryMock.stubGetDefaultQuickLinks(quickLinkRepositoryMock, toReturn: quickLinks(intl));

        final result = await viewModel.getUserQuickLinks();

        expect(result.visible, [quickLinkSample]);
        expect(result.hidden, isEmpty);
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
        QuickLinkRepositoryMock.stubGetQuickLinks(quickLinkRepositoryMock, toReturn: [quickLinkSample]);
        QuickLinkRepositoryMock.stubGetQuickLinkDataFromCache(quickLinkRepositoryMock, toReturn: [quickLinkDataSample]);
        QuickLinkRepositoryMock.stubGetHiddenQuickLinkIdsFromCache(quickLinkRepositoryMock);
        QuickLinkRepositoryMock.stubGetDefaultQuickLinks(quickLinkRepositoryMock, toReturn: [quickLinkSample]);

        final result = await viewModel.futureToRun();

        expect(result, [quickLinkSample]);
      });
    });
  });
}
