import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud_test/nextcloud_test.dart';
import 'package:test/test.dart';

import 'helper.dart';

const wikipediaFeedURL = 'https://en.wikipedia.org/w/api.php?action=featuredfeed&feed=featured&feedformat=atom';
const nasaFeedURL = 'https://www.nasa.gov/rss/dyn/breaking_news.rss';

Future main() async {
  final dockerImageName = await TestHelper.prepareDockerImage(apps: ['news']);

  group('news', () {
    late TestNextcloudClient client;
    setUp(() async {
      client = await TestHelper.getPreparedClient(dockerImageName);
    });
    tearDown(() => client.destroy());

    Future<NewsListFeeds> addWikipediaFeed([final int? folderID]) async => (await validateResponse<NewsListFeeds, void>(
          client.news,
          client.news.addFeedWithHttpInfo(
            NewsAddFeed(
              url: wikipediaFeedURL,
              folderId: folderID,
            ),
          ),
          cleanResponse: true,
        ))!;

    Future<NewsListFeeds> addNasaFeed() async => (await validateResponse<NewsListFeeds, void>(
          client.news,
          client.news.addFeedWithHttpInfo(
            NewsAddFeed(url: nasaFeedURL),
          ),
          cleanResponse: true,
        ))!;

    test('Add feed', () async {
      var response = (await validateResponse<NewsListFeeds, void>(
        client.news,
        client.news.listFeedsWithHttpInfo(),
        cleanResponse: true,
      ))!;
      expect(response.starredCount, 0);
      expect(response.newestItemId, null);
      expect(response.feeds, hasLength(0));

      response = await addWikipediaFeed();
      expect(response.starredCount, null);
      expect(response.newestItemId, isNotNull);
      expect(response.feeds, hasLength(1));
      expect(response.feeds[0].url, wikipediaFeedURL);

      response = (await validateResponse<NewsListFeeds, void>(
        client.news,
        client.news.listFeedsWithHttpInfo(),
      ))!;
      expect(response.starredCount, 0);
      expect(response.newestItemId, isNotNull);
      expect(response.feeds, hasLength(1));
      expect(response.feeds[0].url, wikipediaFeedURL);
    });

    test('Mark feed as read', () async {
      final feedsResponse = await addWikipediaFeed();

      var articlesResponse = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(type: 6),
      ))!;
      expect(articlesResponse.items.length, greaterThan(0));

      await client.news.markFeedAsRead(
        feedsResponse.feeds[0].id!,
        NewsMarkAsRead(
          newestItemId: feedsResponse.newestItemId,
        ),
      );

      articlesResponse = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(type: 6),
      ))!;
      expect(articlesResponse.items, hasLength(0));
    });

    test('List articles', () async {
      var response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(),
      ))!;
      expect(response.items, hasLength(0));

      await addWikipediaFeed();

      response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(),
      ))!;
      expect(response.items.length, greaterThan(0));
      expect(response.items[0].body, isNotNull);
      expect(response.items[0].feedId, 1);
      expect(response.items[0].unread, true);
      expect(response.items[0].starred, false);
    });

    test('List updated articles', () async {
      // Testing this is not easy, because we can't depend on an external source to update the feed
      // Therefore we just add a second feed and check that the articles returned after a certain modified timestamp
      // are exactly those of the new feed.
      // Now that I think of it, maybe we could host our own feed and update that way, but this works for now.

      await addWikipediaFeed();

      var response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(),
      ))!;
      final wikipediaArticles = response.items.length;
      expect(wikipediaArticles, greaterThan(0));

      await addNasaFeed();

      response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(),
      ))!;
      final nasaArticles = response.items.length - wikipediaArticles;
      expect(nasaArticles, greaterThan(0));

      response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listUpdatedArticlesWithHttpInfo(
          lastModified: response.items[response.items.length - 1 - nasaArticles].lastModified,
        ),
      ))!;
      expect(response.items, hasLength(nasaArticles));
    });

    test('Mark article as read', () async {
      await addWikipediaFeed();

      var response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(type: 6),
      ))!;
      final unreadArticles = response.items.length;
      expect(unreadArticles, greaterThan(0));

      await client.news.markArticleAsRead(response.items[0].id!);
      response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(type: 6),
      ))!;
      expect(response.items, hasLength(unreadArticles - 1));
    });

    test('Mark article as unread', () async {
      await addWikipediaFeed();

      var response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(type: 6),
      ))!;
      final readArticle = response.items[0];
      await client.news.markArticleAsRead(readArticle.id!);
      response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(type: 6),
      ))!;
      final unreadArticles = response.items.length;
      expect(unreadArticles, greaterThan(0));

      await client.news.markArticleAsUnread(readArticle.id!);
      response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(type: 6),
      ))!;
      expect(response.items, hasLength(unreadArticles + 1));
    });

    test('Star article', () async {
      await addWikipediaFeed();

      var response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(type: 2),
      ))!;
      final starredArticles = response.items.length;
      expect(starredArticles, 0);

      response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(),
      ))!;
      await client.news.starArticle(response.items[0].feedId!, response.items[0].guidHash!);
      response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(type: 2),
      ))!;
      expect(response.items, hasLength(1));
    });

    test('Unstar article', () async {
      await addWikipediaFeed();

      var response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(),
      ))!;
      final item = response.items[0];

      await client.news.starArticle(item.feedId!, item.guidHash!);
      response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(type: 2),
      ))!;
      expect(response.items, hasLength(1));

      await client.news.unstarArticle(item.feedId!, item.guidHash!);
      response = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(type: 2),
      ))!;
      expect(response.items, hasLength(0));
    });

    test('Create folder', () async {
      var response = (await validateResponse<NewsListFolders, void>(
        client.news,
        client.news.listFoldersWithHttpInfo(),
      ))!;
      expect(response.folders, hasLength(0));

      response = (await validateResponse<NewsListFolders, void>(
        client.news,
        client.news.createFolderWithHttpInfo(NewsCreateFolder(name: 'test')),
      ))!;
      expect(response.folders, hasLength(1));
      expect(response.folders[0].id, 1);
      expect(response.folders[0].name, 'test');
      expect(response.folders[0].opened, true);
      expect(response.folders[0].feeds, hasLength(0));

      response = (await validateResponse<NewsListFolders, void>(
        client.news,
        client.news.listFoldersWithHttpInfo(),
      ))!;
      expect(response.folders, hasLength(1));
      expect(response.folders[0].id, 1);
      expect(response.folders[0].name, 'test');
      expect(response.folders[0].opened, true);
      expect(response.folders[0].feeds, hasLength(0));
    });

    test('List folders', () async {
      var response = (await validateResponse<NewsListFolders, void>(
        client.news,
        client.news.listFoldersWithHttpInfo(),
      ))!;
      expect(response.folders, hasLength(0));

      await client.news.createFolder(NewsCreateFolder(name: 'test1'));
      await client.news.createFolder(NewsCreateFolder(name: 'test2'));

      response = (await validateResponse<NewsListFolders, void>(
        client.news,
        client.news.listFoldersWithHttpInfo(),
      ))!;
      expect(response.folders, hasLength(2));
      expect(response.folders[0].id, 1);
      expect(response.folders[0].name, 'test1');
      expect(response.folders[0].opened, true);
      expect(response.folders[0].feeds, hasLength(0));
      expect(response.folders[1].id, 2);
      expect(response.folders[1].name, 'test2');
      expect(response.folders[1].opened, true);
      expect(response.folders[1].feeds, hasLength(0));
    });

    test('Add feed to folder', () async {
      await client.news.createFolder(NewsCreateFolder(name: 'test1'));
      final response = await addWikipediaFeed(1);
      expect(response.starredCount, null);
      expect(response.newestItemId, isNotNull);
      expect(response.feeds, hasLength(1));
      expect(response.feeds[0].folderId, 1);
      expect(response.feeds[0].url, wikipediaFeedURL);
    });

    test('Mark folder as read', () async {
      final foldersResponse = (await validateResponse<NewsListFolders, void>(
        client.news,
        client.news.createFolderWithHttpInfo(NewsCreateFolder(name: 'test1')),
      ))!;
      final feedsResponse = await addWikipediaFeed(1);

      var articlesResponse = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(type: 6),
      ))!;
      expect(articlesResponse.items.length, greaterThan(0));

      await client.news.markFolderAsRead(
        foldersResponse.folders[0].id!,
        NewsMarkAsRead(
          newestItemId: feedsResponse.newestItemId,
        ),
      );

      articlesResponse = (await validateResponse<NewsListArticles, void>(
        client.news,
        client.news.listArticlesWithHttpInfo(type: 6),
      ))!;
      expect(articlesResponse.items, hasLength(0));
    });
  });
}
