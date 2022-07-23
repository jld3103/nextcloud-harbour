part of '../app.dart';

class DownloadTask {
  DownloadTask({
    required this.path,
  });

  final List<String> path;

  final _streamController = StreamController<int>();
  late final progress = _streamController.stream.asBroadcastStream();

  Future execute(final NextcloudClient client, final File file) async {
    await client.webdav.downloadFile(
      path.join('/'),
      file,
      onProgress: (final progress) {
        _streamController.add(progress.toInt());
      },
    );
  }
}
