part of '../app.dart';

class UploadTask {
  UploadTask({
    required this.path,
    required this.stat,
  });

  final List<String> path;
  final FileStat stat;

  final _streamController = StreamController<int>();
  late final progress = _streamController.stream.asBroadcastStream();

  Future execute(final NextcloudClient client, final File file) async {
    await client.webdav.uploadFile(
      file,
      stat,
      path.join('/'),
      onProgress: (final progress) {
        _streamController.add(progress.toInt());
      },
    );
  }
}
