import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud_test/nextcloud_test.dart';
import 'package:test/test.dart';

import 'helper.dart';

Future main() async {
  final dockerImageName = await TestHelper.prepareDockerImage();

  group('webdav', () {
    late TestNextcloudClient client;
    setUp(() async {
      client = await TestHelper.getPreparedClient(dockerImageName);
    });
    tearDown(() => client.destroy());

    test('Fail without username', () async {
      await client.destroy();
      client = await TestHelper.getPreparedClient(dockerImageName, username: null);
      expect(() => client.webdav, throwsException);
    });

    test('Get status', () async {
      final status = await client.webdav.status();
      expect(status.capabilities, containsAll(['1', '3', 'access-control']));
      expect(status.searchCapabilities, hasLength(0));
    });

    test('List directory', () async {
      final files = await client.webdav.ls(
        '/',
        props: {
          WebDavProps.ncHasPreview.name,
          WebDavProps.davContentType.name,
          WebDavProps.davLastModified.name,
          WebDavProps.ocSize.name,
        },
      );
      expect(files, hasLength(7));
      final file = files.singleWhere((final f) => f.name == 'Nextcloud.png');
      expect(file.hasPreview, isTrue);
      expect(file.mimeType, 'image/png');
      expectDateInReasonableTimeRange(file.lastModified!, DateTime.now());
      expect(file.size!, 50598);
    });

    test('Create directory', () async {
      final response = await client.webdav.mkdir('test');
      expect(response.statusCode, equals(201));
    });

    test('Create directory recursively', () async {
      final response = await client.webdav.mkdirs('test/bla');
      expect(response!.statusCode, equals(201));

      final files = await client.webdav.ls('/test');
      expect(files, hasLength(1));
      expect(files[0].path, '/test/bla/');
    });

    test('Upload files', () async {
      final pngBytes = File('test/files/test.png').readAsBytesSync();
      final txtBytes = File('test/files/test.txt').readAsBytesSync();

      var response = await client.webdav.upload(pngBytes, 'test.png');
      expect(response.statusCode, equals(201));

      response = await client.webdav.upload(txtBytes, 'test.txt');
      expect(response.statusCode, equals(201));

      final files = await client.webdav.ls(
        '/',
        props: {
          WebDavProps.ocSize.name,
        },
      );
      expect(files, hasLength(9));
      final pngFile = files.singleWhere((final f) => f.name == 'test.png');
      final txtFile = files.singleWhere((final f) => f.name == 'test.txt');
      expect(pngFile.size, pngBytes.lengthInBytes);
      expect(txtFile.size, txtBytes.lengthInBytes);
    });

    test('Copy file', () async {
      final response = await client.webdav.copy(
        'Nextcloud.png',
        'test.png',
      );
      expect(response.statusCode, 201);
      final files = await client.webdav.ls('/');
      expect(files.where((final f) => f.name == 'Nextcloud.png'), hasLength(1));
      expect(files.where((final f) => f.name == 'test.png'), hasLength(1));
    });

    test('Copy file (overwrite fail)', () async {
      await client.webdav.upload(Uint8List.fromList(utf8.encode('1')), '1.txt');
      await client.webdav.upload(Uint8List.fromList(utf8.encode('2')), '2.txt');

      expect(
        () => client.webdav.copy('1.txt', '2.txt'),
        throwsA(predicate((final e) => (e! as ApiException).code == 412)),
      );
    });

    test('Copy file (overwrite success)', () async {
      await client.webdav.upload(Uint8List.fromList(utf8.encode('1')), '1.txt');
      await client.webdav.upload(Uint8List.fromList(utf8.encode('2')), '2.txt');

      final response = await client.webdav.copy(
        '1.txt',
        '2.txt',
        overwrite: true,
      );
      expect(response.statusCode, 204);
    });

    test('Move file', () async {
      final response = await client.webdav.move(
        'Nextcloud.png',
        'test.png',
      );
      expect(response.statusCode, 201);
      final files = await client.webdav.ls('/');
      expect(files.where((final f) => f.name == 'Nextcloud.png'), hasLength(0));
      expect(files.where((final f) => f.name == 'test.png'), hasLength(1));
    });

    test('Move file (overwrite fail)', () async {
      await client.webdav.upload(Uint8List.fromList(utf8.encode('1')), '1.txt');
      await client.webdav.upload(Uint8List.fromList(utf8.encode('2')), '2.txt');

      expect(
        () => client.webdav.move('1.txt', '2.txt'),
        throwsA(predicate((final e) => (e! as ApiException).code == 412)),
      );
    });

    test('Move file (overwrite success)', () async {
      await client.webdav.upload(Uint8List.fromList(utf8.encode('1')), '1.txt');
      await client.webdav.upload(Uint8List.fromList(utf8.encode('2')), '2.txt');

      final response = await client.webdav.move(
        '1.txt',
        '2.txt',
        overwrite: true,
      );
      expect(response.statusCode, 204);
    });

    test('Get file props', () async {
      final file = await client.webdav.getProps(
        'Nextcloud.png',
        props: {
          WebDavProps.ncHasPreview.name,
          WebDavProps.davContentType.name,
          WebDavProps.davLastModified.name,
          WebDavProps.ocSize.name,
        },
      );
      expect(file.hasPreview, isTrue);
      expect(file.mimeType, 'image/png');
      expectDateInReasonableTimeRange(file.lastModified!, DateTime.now());
      expect(file.size!, 50598);
    });

    test('Get directory props', () async {
      final data = Uint8List.fromList(utf8.encode('test'));
      await client.webdav.mkdir('test');
      await client.webdav.upload(data, 'test/test.txt');

      final file = await client.webdav.getProps(
        'test',
        props: {
          WebDavProps.davResourceType.name,
          WebDavProps.davContentType.name,
          WebDavProps.davLastModified.name,
          WebDavProps.ocSize.name,
        },
      );
      expect(file.isDirectory, isTrue);
      expect(file.name, 'test');
      expect(file.mimeType, null);
      expectDateInReasonableTimeRange(file.lastModified!, DateTime.now());
      expect(file.size!, data.lengthInBytes);
    });

    test('Filter files', () async {
      final response = await client.webdav.upload(Uint8List.fromList(utf8.encode('test')), 'test.txt');
      final id = response.headers['oc-fileid']!.first;
      await client.webdav.updateProps('test.txt', {WebDavProps.ocFavorite.name: '1'});

      final files = await client.webdav.filter(
        '/',
        {
          WebDavProps.ocFavorite.name: '1',
        },
        props: {
          WebDavProps.ocId.name,
          WebDavProps.ocFavorite.name,
        },
      );
      expect(files, hasLength(1));
      final file = files.singleWhere((final e) => e.name == 'test.txt');
      expect(file.id, id);
      expect(file.favorite, isTrue);
    });

    test('Set properties', () async {
      final createdDate = DateTime.utc(1971, 2);
      final createdEpoch = createdDate.millisecondsSinceEpoch / 1000;
      final uploadTime = DateTime.now();

      await client.webdav.upload(Uint8List.fromList(utf8.encode('test')), 'test.txt');

      final updated = await client.webdav.updateProps('test.txt', {
        WebDavProps.ocFavorite.name: '1',
        WebDavProps.ncCreationTime.name: '$createdEpoch',
      });
      expect(updated, isTrue);

      final file = await client.webdav.getProps(
        'test.txt',
        props: {
          WebDavProps.ocFavorite.name,
          WebDavProps.ncCreationTime.name,
          WebDavProps.ncUploadTime.name,
        },
      );
      expect(file.favorite, isTrue);
      expect(file.createdDate!.isAtSameMomentAs(createdDate), isTrue);
      expectDateInReasonableTimeRange(file.uploadedDate!, uploadTime);
    });

    test('Set custom properties', () async {
      client.webdav.registerNamespace('http://example.com/ns', 'test');

      await client.webdav.upload(Uint8List.fromList(utf8.encode('test')), 'test.txt');

      final updated = await client.webdav.updateProps('test.txt', {
        'test:custom': 'test-custom-prop-value',
      });
      expect(updated, isTrue);

      final file = await client.webdav.getProps(
        'test.txt',
        props: {
          'test:custom',
        },
      );

      expect(
        file.getProp('test:custom')!.text,
        'test-custom-prop-value',
      );
    });
  });
}
