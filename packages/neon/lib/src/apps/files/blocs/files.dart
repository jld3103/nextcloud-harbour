import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:neon/src/apps/files/app.dart';
import 'package:neon/src/apps/files/blocs/browser.dart';
import 'package:neon/src/neon.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:queue/queue.dart';
import 'package:rx_bloc/rx_bloc.dart';
import 'package:rxdart/rxdart.dart';

part 'files.rxb.g.dart';

abstract class FilesBlocEvents {
  void refresh();

  void uploadFile(final List<String> path, final String localPath);

  void syncFile(final List<String> path);

  void openFile(final List<String> path, final String etag, final String? mimeType);

  void delete(final List<String> path);

  void rename(final List<String> path, final String name);

  void move(final List<String> path, final List<String> destination);

  void copy(final List<String> path, final List<String> destination);

  void addFavorite(final List<String> path);

  void removeFavorite(final List<String> path);
}

abstract class FilesBlocStates {
  BehaviorSubject<List<UploadTask>> get uploadTasks;

  BehaviorSubject<List<DownloadTask>> get downloadTasks;

  Stream<Exception> get errors;
}

@RxBloc()
class FilesBloc extends $FilesBloc {
  FilesBloc(
    this.options,
    this._requestManager,
    this.client,
    this._platform,
  ) {
    _$refreshEvent.listen((final _) => browser.refresh());

    _$uploadFileEvent.listen((final event) {
      _wrapAction(
        true,
        () async {
          final file = File(event.localPath);
          // ignore: avoid_slow_async_io
          final stat = await file.stat();
          final task = UploadTask(
            path: event.path,
            stat: stat,
          );
          _uploadTasksSubject.add(_uploadTasksSubject.value..add(task));
          await _uploadQueue.add(() => task.execute(client, file));
          _uploadTasksSubject.add(_uploadTasksSubject.value..removeWhere((final t) => t == task));
        },
      );
    });

    _$syncFileEvent.listen((final path) {
      final stream = _requestManager.wrapWithoutCache(
        () async {
          final file = File(
            p.join(
              await _platform.getUserAccessibleAppDataPath(),
              '${client.username!}@${Uri.parse(client.baseURL).host}',
              'files',
              path.join(Platform.pathSeparator),
            ),
          );
          if (!file.parent.existsSync()) {
            file.parent.createSync(recursive: true);
          }
          return _downloadFile(path, file);
        },
        disableTimeout: true,
      ).asBroadcastStream();
      stream.whereError().listen(_errorsStreamController.add);
    });

    _$openFileEvent.listen((final event) {
      _wrapAction(
        true,
        () async {
          final file = File(
            p.join(
              await _platform.getApplicationCachePath(),
              'files',
              event.etag.replaceAll('"', ''),
              event.path.last,
            ),
          );
          if (!file.existsSync()) {
            debugPrint('Downloading ${event.path.join('/')} since it does not exist');
            if (!file.parent.existsSync()) {
              await file.parent.create(recursive: true);
            }
            await _downloadFile(event.path, file);
          }
          await OpenFile.open(file.path, type: event.mimeType);
        },
      );
    });

    _$deleteEvent.listen((final path) {
      _wrapAction(false, () async => client.webdav.delete(path.join('/')));
    });

    _$renameEvent.listen((final event) {
      _wrapAction(
        false,
        () async => client.webdav.move(
          event.path.join('/'),
          (event.path.sublist(0, event.path.length - 1)..add(event.name)).join('/'),
        ),
      );
    });

    _$moveEvent.listen((final event) {
      _wrapAction(
        false,
        () async => client.webdav.move(
          event.path.join('/'),
          event.destination.join('/'),
        ),
      );
    });

    _$copyEvent.listen((final event) {
      _wrapAction(
        false,
        () async => client.webdav.copy(
          event.path.join('/'),
          event.destination.join('/'),
        ),
      );
    });

    _$addFavoriteEvent.listen((final path) {
      _wrapAction(
        false,
        () async => client.webdav.updateProps(
          path.join('/'),
          {WebDavProps.ocFavorite.name: '1'},
        ),
      );
    });

    _$removeFavoriteEvent.listen((final path) {
      _wrapAction(
        false,
        () async => client.webdav.updateProps(
          path.join('/'),
          {WebDavProps.ocFavorite.name: '0'},
        ),
      );
    });

    options.uploadQueueParallelism.stream.listen((final value) {
      _uploadQueue.parallel = value;
    });
    options.downloadQueueParallelism.stream.listen((final value) {
      _downloadQueue.parallel = value;
    });
  }

  Future _downloadFile(
    final List<String> path,
    final File file,
  ) async {
    try {
      final task = DownloadTask(path: path);
      _downloadTasksSubject.add(_downloadTasksSubject.value..add(task));
      await _downloadQueue.add(() => task.execute(client, file));
      _downloadTasksSubject.add(_downloadTasksSubject.value..removeWhere((final t) => t == task));
    } catch (e) {
      rethrow;
    }
  }

  void _wrapAction(final bool disableTimeout, final Future Function() call) {
    final stream = _requestManager.wrapWithoutCache(call, disableTimeout: disableTimeout).asBroadcastStream();
    stream.whereError().listen(_errorsStreamController.add);
    stream.whereSuccess().listen((final _) async {
      browser.refresh();
    });
  }

  FilesBrowserBloc getNewFilesBrowserBloc() => FilesBrowserBloc(options, _requestManager, client);

  final FilesAppSpecificOptions options;
  final RequestManager _requestManager;
  final NextcloudClient client;
  final NeonPlatform _platform;
  late final browser = getNewFilesBrowserBloc();

  final _uploadQueue = Queue();
  final _downloadQueue = Queue();
  final _uploadTasksSubject = BehaviorSubject<List<UploadTask>>.seeded([]);
  final _downloadTasksSubject = BehaviorSubject<List<DownloadTask>>.seeded([]);
  final _errorsStreamController = StreamController<Exception>();

  @override
  void dispose() {
    _uploadQueue.dispose();
    _downloadQueue.dispose();
    // ignore: discarded_futures
    _uploadTasksSubject.close();
    // ignore: discarded_futures
    _downloadTasksSubject.close();
    // ignore: discarded_futures
    _errorsStreamController.close();
    super.dispose();
  }

  @override
  BehaviorSubject<List<UploadTask>> _mapToUploadTasksState() => _uploadTasksSubject;

  @override
  BehaviorSubject<List<DownloadTask>> _mapToDownloadTasksState() => _downloadTasksSubject;

  @override
  Stream<Exception> _mapToErrorsState() => _errorsStreamController.stream.asBroadcastStream();
}
