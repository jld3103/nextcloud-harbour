part of 'webdav.dart';

/// WebDavClient class
class WebDavClient {
  // ignore: public_member_api_docs
  WebDavClient(
    this.baseUrl, {
    this.basePath = '',
    this.baseHeaders,
  });

  /// Base URL of the server
  final String baseUrl;

  /// Base path used on the server
  final String basePath;

  /// Headers added to each request. Useful for authentication
  final Map<String, String>? baseHeaders;

  /// XML namespaces supported by this client.
  ///
  /// For Nextcloud namespaces see [WebDav/Requesting properties](https://docs.nextcloud.com/server/latest/developer_manual/client_apis/WebDAV/basic.html#requesting-properties).
  final Map<String, String> namespaces = {
    'DAV:': 'd',
    'http://owncloud.org/ns': 'oc',
    'http://nextcloud.org/ns': 'nc',
    'http://open-collaboration-services.org/ns': 'ocs',
    'http://open-cloud-mesh.org/ns': 'ocm',
    'http://sabredav.org/ns': 's', // mostly used in error responses
  };

  Future<HttpClientResponse> _send(
    final String method,
    final String url,
    final List<int> expectedCodes, {
    final Stream<Uint8List>? data,
    final Map<String, String>? headers,
  }) async {
    final request = await HttpClient().openUrl(
      method,
      Uri.parse(url),
    )
      ..followRedirects = false
      ..persistentConnection = true;
    for (final header in {
      HttpHeaders.contentTypeHeader: 'application/xml',
      if (baseHeaders != null) ...baseHeaders!,
      if (headers != null) ...headers,
    }.entries) {
      request.headers.add(header.key, header.value);
    }

    if (data != null) {
      await request.addStream(data);
    }

    final response = await request.close();

    if (!expectedCodes.contains(response.statusCode)) {
      throw ApiException(
        response.statusCode,
        await response.body,
      );
    }

    return response;
  }

  /// Registers a custom namespace for properties.
  ///
  /// Requires a unique [namespaceUri] and [prefix].
  void registerNamespace(final String namespaceUri, final String prefix) =>
      namespaces.putIfAbsent(namespaceUri, () => prefix);

  String _constructPath([final String? path]) => [
        baseUrl,
        basePath,
        if (path != null) ...[
          path,
        ],
      ]
          .map((part) {
            while (part.startsWith('/')) {
              part = part.substring(1);
            }
            while (part.endsWith('/')) {
              part = part.substring(0, part.length - 1);
            }
            return part;
          })
          .where((final part) => part.isNotEmpty)
          .join('/');

  String _buildPropsRequest(final Set<String> props) {
    final builder = xml.XmlBuilder();
    builder
      ..processing('xml', 'version="1.0"')
      ..element(
        'd:propfind',
        nest: () {
          namespaces.forEach(builder.namespace);
          builder.element(
            'd:prop',
            nest: () {
              props.forEach(builder.element);
            },
          );
        },
      );
    return builder.buildDocument().toString();
  }

  /// returns the WebDAV capabilities of the server
  Future<WebDavStatus> status() async {
    final response = await _send(
      'OPTIONS',
      _constructPath(),
      [200],
    );
    final davCapabilities = response.headers['dav']?.cast<String>().first ?? '';
    final davSearchCapabilities = response.headers['dasl']?.cast<String>().first ?? '';
    return WebDavStatus(
      davCapabilities.split(',').map((final e) => e.trim()).where((final e) => e.isNotEmpty).toSet(),
      davSearchCapabilities.split(',').map((final e) => e.trim()).where((final e) => e.isNotEmpty).toSet(),
    );
  }

  /// make a dir with [remotePath] under current dir
  Future<HttpClientResponse> mkdir(
    final String remotePath, {
    final bool safe = true,
  }) async {
    final expectedCodes = [
      201,
      if (safe) ...[
        301,
        405,
      ],
    ];
    return _send(
      'MKCOL',
      _constructPath(remotePath),
      expectedCodes,
    );
  }

  /// just like mkdir -p
  Future<HttpClientResponse?> mkdirs(
    final String remotePath, {
    final bool safe = true,
  }) async {
    final dirs = remotePath.trim().split('/')..removeWhere((final value) => value == '');
    if (dirs.isEmpty) {
      return null;
    }
    if (remotePath.trim().startsWith('/')) {
      dirs[0] = '/${dirs[0]}';
    }
    final prevPath = StringBuffer();
    late HttpClientResponse response;
    for (final dir in dirs) {
      response = await mkdir(
        '$prevPath/$dir',
        safe: safe,
      );
      prevPath.write('/$dir');
    }

    return response;
  }

  /// remove dir with given [path]
  Future<HttpClientResponse> delete(final String path) => _send(
        'DELETE',
        _constructPath(path),
        [204],
      );

  /// upload a new file with [localData] as content to [remotePath]
  Future<HttpClientResponse> upload(final Uint8List localData, final String remotePath) => _send(
        'PUT',
        _constructPath(remotePath),
        [200, 201, 204],
        data: Stream.value(localData),
      );

  /// upload a new file with [localData] as content to [remotePath]
  Future<HttpClientResponse> uploadStream(final Stream<Uint8List> localData, final String remotePath) async => _send(
        'PUT',
        _constructPath(remotePath),
        [200, 201, 204],
        data: localData,
      );

  /// Stream the content from [file] to [remotePath]
  Future uploadFile(
    final File file,
    final FileStat fileStat,
    final String remotePath, {
    final Function(double progres)? onProgress,
  }) async {
    var uploaded = 0;
    await uploadStream(
      file.openRead().map((final chunk) {
        uploaded += chunk.length;
        onProgress?.call(uploaded / fileStat.size * 100);
        return Uint8List.fromList(chunk);
      }),
      remotePath,
    );
  }

  /// download [remotePath] and store the response file contents to String
  Future<Uint8List> download(final String remotePath) async => Uint8List.fromList(
        (await (await _send(
          'GET',
          _constructPath(remotePath),
          [200],
        ))
                .join())
            .codeUnits,
      );

  /// download [remotePath] and store the response file contents to ByteStream
  Future<HttpClientResponse> downloadStream(final String remotePath) async => _send(
        'GET',
        _constructPath(remotePath),
        [200],
      );

  /// download [remotePath] and stream the content into [file]
  Future downloadFile(
    final String remotePath,
    final File file, {
    final Function(double progress)? onProgress,
  }) async {
    final sink = file.openWrite();
    final completer = Completer();
    final response = await downloadStream(remotePath);
    var downloaded = 0;

    response.listen((final chunk) async {
      sink.add(chunk);
      downloaded += chunk.length;
      onProgress?.call(downloaded / response.contentLength * 100);
      if (downloaded >= response.contentLength) {
        completer.complete();
      }
    });

    await completer.future;
    await sink.close();
  }

  /// list the directories and files under given [remotePath].
  ///
  /// Optionally populates the given [props] on the returned files.
  /// [depth] can be '0', '1' or 'infinity'.
  Future<List<WebDavFile>> ls(
    final String remotePath, {
    final Set<String>? props,
    final String? depth,
  }) async {
    final response = await _send(
      'PROPFIND',
      _constructPath(remotePath),
      [207, 301],
      data: Stream.value(Uint8List.fromList(utf8.encode(_buildPropsRequest(props ?? {})))),
      headers: {
        if (depth != null) ...{
          'Depth': depth,
        },
      },
    );
    if (response.statusCode == 301) {
      return ls(response.headers['location']!.first);
    }
    return treeFromWebDavXml(
      basePath,
      namespaces,
      await response.body,
    )..removeAt(0);
  }

  /// Runs the filter-files report with the given [propFilters] on the
  /// [remotePath].
  ///
  /// Optionally populates the given [props] on the returned files.
  Future<List<WebDavFile>> filter(
    final String remotePath,
    final Map<String, String> propFilters, {
    final Set<String> props = const {},
  }) async {
    final builder = xml.XmlBuilder();
    builder
      ..processing('xml', 'version="1.0"')
      ..element(
        'oc:filter-files',
        nest: () {
          namespaces.forEach(builder.namespace);
          builder
            ..element(
              'oc:filter-rules',
              nest: () {
                propFilters.forEach((final key, final value) {
                  builder.element(
                    key,
                    nest: () {
                      builder.text(value);
                    },
                  );
                });
              },
            )
            ..element(
              'd:prop',
              nest: () {
                props.forEach(builder.element);
              },
            );
        },
      );
    final response = await _send(
      'REPORT',
      _constructPath(remotePath),
      [200, 207],
      data: Stream.value(Uint8List.fromList(utf8.encode(builder.buildDocument().toString()))),
    );
    return treeFromWebDavXml(
      basePath,
      namespaces,
      await response.body,
    );
  }

  /// Retrieves properties for the given [remotePath].
  ///
  /// Populates all available properties by default, but a reduced set can be
  /// specified via [props].
  Future<WebDavFile> getProps(
    final String remotePath, {
    final Set<String>? props,
  }) async {
    final response = await _send(
      'PROPFIND',
      _constructPath(remotePath),
      [200, 207],
      data: Stream.value(Uint8List.fromList(utf8.encode(_buildPropsRequest(props ?? {})))),
      headers: {'Depth': '0'},
    );
    return fileFromWebDavXml(
      basePath,
      namespaces,
      await response.body,
    );
  }

  /// Update (string) properties of the given [remotePath].
  ///
  /// Returns true if the update was successful.
  Future<bool> updateProps(
    final String remotePath,
    final Map<String, String> props,
  ) async {
    final builder = xml.XmlBuilder();
    builder
      ..processing('xml', 'version="1.0"')
      ..element(
        'd:propertyupdate',
        nest: () {
          namespaces.forEach(builder.namespace);
          builder.element(
            'd:set',
            nest: () {
              builder.element(
                'd:prop',
                nest: () {
                  props.forEach((final key, final value) {
                    builder.element(
                      key,
                      nest: () {
                        builder.text(value);
                      },
                    );
                  });
                },
              );
            },
          );
        },
      );
    final response = await _send(
      'PROPPATCH',
      _constructPath(remotePath),
      [200, 207],
      data: Stream.value(Uint8List.fromList(utf8.encode(builder.buildDocument().toString()))),
    );
    return checkUpdateFromWebDavXml(await response.body);
  }

  /// Move a file from [sourcePath] to [destinationPath]
  Future<HttpClientResponse> move(
    final String sourcePath,
    final String destinationPath, {
    final bool overwrite = false,
  }) =>
      _send(
        'MOVE',
        _constructPath(sourcePath),
        [200, 201, 204],
        headers: {
          'Destination': _constructPath(destinationPath),
          'Overwrite': overwrite ? 'T' : 'F',
        },
      );

  /// Copy a file from [sourcePath] to [destinationPath]
  Future<HttpClientResponse> copy(
    final String sourcePath,
    final String destinationPath, {
    final bool overwrite = false,
  }) =>
      _send(
        'COPY',
        _constructPath(sourcePath),
        [200, 201, 204],
        headers: {
          'Destination': _constructPath(destinationPath),
          'Overwrite': overwrite ? 'T' : 'F',
        },
      );
}

/// WebDAV server status.
class WebDavStatus {
  /// Creates a new WebDavStatus.
  WebDavStatus(
    this.capabilities,
    this.searchCapabilities,
  );

  /// DAV capabilities as advertised by the server in the 'dav' header.
  Set<String> capabilities;

  /// DAV search and locating capabilities as advertised by the server in the
  /// 'dasl' header.
  Set<String> searchCapabilities;
}
