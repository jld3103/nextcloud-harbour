part of 'webdav.dart';

/// File sync helper
extension FileSync on WebDavClient {
  /// Syncs files and directories in both ways
  Future<List<FileSyncSummaryEntry>> sync(
    final String remotePath,
    final FileSyncStore store, {
    final bool recursively = true,
    final bool force = false,
  }) async {
    final operations = <FileSyncSummaryEntry>[];

    final remoteFiles = await ls(remotePath, depth: 'infinity');
    final localFiles = store.basePath.listSync(recursive: true);

    final changedRemoteFiles = <WebDavFile>[];
    for (final remoteFile in remoteFiles) {
      if (store.hasRemoteChanged(remoteFile)) {
        changedRemoteFiles.add(remoteFile);
      }
    }

    final changedLocalFiles = <FileSystemEntity>[];
    for (final localFile in localFiles) {
      if (store.hasLocalChanged(localFile)) {
        changedLocalFiles.add(localFile);
      }
    }

    final conflicts = <FileSyncConflict>[];
    for (final remoteFile in changedRemoteFiles) {
      for (final localFile in changedLocalFiles) {
        // TODO
      }
    }

    for (final remoteFile in changedRemoteFiles) {
      if (remoteFile.isDirectory) {
        // TODO
        continue;
      }
      final localFile = File(store.getRemoteFileAbsolutePath(remoteFile));
      await localFile.parent.create(recursive: true);

      await downloadFile(remoteFile.path, localFile);

      operations.add(
        FileSyncSummaryEntry(
          remoteFile: remoteFile,
          localFile: localFile,
          type: FileSyncSummaryEntryType.downloaded,
        ),
      );
      store.add(remoteFile, localFile);
    }

    return operations;
  }
}

// ignore: public_member_api_docs
class FileSyncConflict {
  // ignore: public_member_api_docs
  FileSyncConflict({
    required this.remoteFile,
    required this.localFile,
  });

  // ignore: public_member_api_docs
  final WebDavFile remoteFile;

  // ignore: public_member_api_docs
  final File localFile;
}

// ignore: public_member_api_docs
class FileSyncSummaryEntry {
  // ignore: public_member_api_docs
  FileSyncSummaryEntry({
    required this.remoteFile,
    required this.localFile,
    required this.type,
  });

  // ignore: public_member_api_docs
  final WebDavFile remoteFile;

  // ignore: public_member_api_docs
  final File localFile;

  // ignore: public_member_api_docs
  final FileSyncSummaryEntryType type;
}

// ignore: public_member_api_docs
enum FileSyncSummaryEntryType {
  /// File was uploaded during sync
  uploaded,

  /// File was downloaded during sync
  downloaded,

  /// File was deleted on remote during sync
  deletedRemote,

  /// File was deleted on local during sync
  deletedLocal,
}

/// Remembers sync states
abstract class FileSyncStore {
  // ignore: public_member_api_docs
  FileSyncStore(this.basePath);

  /// Base path of the store
  final Directory basePath;

  String? _getRemoteHash(final String path);

  void _setRemoteHash(final String path, final String hash);

  String? _getLocalHash(final String path);

  void _setLocalHash(final String path, final String hash);

  /// Add entries for [remoteFile] and [localFile] to the store
  void add(WebDavFile remoteFile, FileSystemEntity localFile) {
    _setRemoteHash(remoteFile.path, remoteFile.etag!);
    _setLocalHash(getLocalFileRelativePath(localFile), _computeLocalHash(localFile));
  }

  /// Check if the remote [file] is different from what is in the store
  bool hasRemoteChanged(WebDavFile file) => _getRemoteHash(file.path) != file.etag!;

  /// Check if the local [file] is different from what is in the store
  bool hasLocalChanged(FileSystemEntity file) =>
      _getLocalHash(getLocalFileRelativePath(file)) != _computeLocalHash(file);

  String _computeLocalHash(FileSystemEntity file) {
    late String fileHash;
    if (file is Directory) {
      fileHash = sha1.convert(utf8.encode(file.listSync().map(_computeLocalHash).join())).toString();
    } else if (file is File) {
      fileHash = sha1.convert([file.statSync().changed.millisecondsSinceEpoch]).toString();
    } else {
      throw Exception('Unknown FileSystemEntity type: ${file.path}');
    }
    return fileHash;
  }

  /// Gets the relative path of a [FileSystemEntity] from the [basePath] of the store on the filesystem
  String getLocalFileRelativePath(FileSystemEntity file) => p.relative(file.path, from: basePath.path);

  /// Gets the absolute path of a [WebDavFile] from the [basePath] of the store on the filesystem
  String getRemoteFileAbsolutePath(WebDavFile file) => p.join(basePath.path, file.path.substring(1));
}

/// In-Memory file sync store
class MemoryFileSyncStore extends FileSyncStore {
  // ignore: public_member_api_docs
  MemoryFileSyncStore(super.basePath);

  final _remoteFiles = <String, String>{};
  final _localFiles = <String, String>{};

  @override
  String? _getRemoteHash(String path) => _remoteFiles[path];

  @override
  void _setRemoteHash(String path, String hash) => _remoteFiles[path] = hash;

  @override
  String? _getLocalHash(String path) => _localFiles[path];

  @override
  void _setLocalHash(String path, String hash) => _localFiles[path] = hash;
}
