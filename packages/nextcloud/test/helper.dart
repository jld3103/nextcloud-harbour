import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:process_run/cmd_run.dart';
import 'package:test/test.dart';

const String nextcloudVersion = '24.0.3';
const String defaultUsername = 'test';
const String defaultPassword = 'supersafepasswordtocircumventpasswordpolicies';

class TestNextcloudClient extends NextcloudClient {
  TestNextcloudClient(
    super.baseURL,
    this.containerID, {
    super.username,
    super.password,
    super.language,
    super.appType,
    super.userAgentOverride,
  });

  final String containerID;

  Future runOccCommand(final List<String> args) async {
    final result = await runExecutableArguments(
      'docker',
      [
        'exec',
        containerID,
        'php',
        '-f',
        'occ',
        ...args,
      ],
      stdout: stdout,
      stderr: stderr,
    );
    if (result.exitCode != 0) {
      throw Exception('Failed to run occ command');
    }
  }

  Future destroy() => runExecutableArguments(
        'docker',
        [
          'kill',
          containerID,
        ],
      );

  Future<String> collectLogs() async {
    final apacheLogs = (await runExecutableArguments(
      'docker',
      [
        'logs',
        containerID,
      ],
      stdoutEncoding: utf8,
    ))
        .stdout as String;
    final nextcloudLogs = (await runExecutableArguments(
      'docker',
      [
        'exec',
        containerID,
        'cat',
        'data/nextcloud.log',
      ],
      stdoutEncoding: utf8,
    ))
        .stdout as String;

    return '$apacheLogs\n\n$nextcloudLogs';
  }
}

class TestHelper {
  static Future<String> prepareDockerImage({
    final List<TestNextcloudUser>? users,
    final List<String>? apps,
  }) async {
    final hash = sha1
        .convert(
          utf8.encode(
            <String>[
              if (users != null)
                for (final user in users) user.toString(),
              if (apps != null) ...apps,
            ].join(),
          ),
        )
        .toString();

    final dockerImageName = 'nextcloud-neon-$hash';

    final inputStream = StreamController<List<int>>();
    final process = runExecutableArguments(
      'docker',
      [
        'build',
        '-t',
        dockerImageName,
        '-f',
        '-',
        './test',
      ],
      stdout: stdout,
      stderr: stderr,
      stdin: inputStream.stream,
    );
    inputStream.add(
      utf8.encode(
        TestDockerHelper.generateInstructions(
          nextcloudVersion,
          users: users,
          apps: apps,
        ),
      ),
    );
    await inputStream.close();

    final result = await process;
    if (result.exitCode != 0) {
      throw Exception('Failed to build docker image');
    }

    return dockerImageName;
  }

  static Future<TestNextcloudClient> getPreparedClient(
    final String dockerImageName, {
    final String? username = defaultUsername,
    final String? password = defaultPassword,
    final bool useAppPassword = false,
    final AppType appType = AppType.unknown,
    final String? userAgentOverride,
  }) async {
    // ignore: prefer_asserts_with_message
    assert(!useAppPassword || (username != null && password != null));

    final port = randomPort();

    final result = await runExecutableArguments(
      'docker',
      [
        'run',
        '--rm',
        '-d',
        '-p',
        '$port:80',
        '--add-host',
        'host.docker.internal:host-gateway',
        dockerImageName,
      ],
    );

    if (result.exitCode != 0) {
      throw Exception('Failed to run docker container: ${result.stderr}');
    }

    final containerID = result.stdout.toString().replaceAll('\n', '');

    var clientPassword = password;
    if (useAppPassword) {
      final inputStream = StreamController<List<int>>();
      final process = runExecutableArguments(
        'docker',
        [
          'exec',
          '-i',
          containerID,
          'php',
          '-f',
          'occ',
          'user:add-app-password',
          username!,
        ],
        stdin: inputStream.stream,
      );
      inputStream.add(utf8.encode(password!));
      await inputStream.close();

      final result = await process;
      if (result.exitCode != 0) {
        throw Exception('Failed to run generate app password command\n${result.stderr}\n${result.stdout}');
      }
      clientPassword = (result.stdout as String).split('\n')[1];
    }

    final client = TestNextcloudClient(
      'http://localhost:$port',
      containerID,
      username: username,
      password: clientPassword,
      appType: appType,
      userAgentOverride: userAgentOverride,
    );

    while (true) {
      // Test will timeout after 30s
      try {
        await client.core.getStatus();
        break;
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    return client;
  }
}

class TestNextcloudUser {
  TestNextcloudUser(
    this.username, {
    this.displayName,
  });

  final String username;
  final String? displayName;
}

class TestDockerHelper {
  static String generateInstructions(
    final String nextcloudVersion, {
    final List<TestNextcloudUser>? users,
    final List<String>? apps,
  }) {
    users?.sort((final a, final b) => a.username.compareTo(b.username));
    apps?.sort();

    final instructions = <String>[
      generateFromNextcloudImageInstruction(nextcloudVersion),
      'WORKDIR /usr/src/nextcloud',
      'RUN chown -R www-data:www-data .',
      'USER www-data',
      'RUN ./occ maintenance:install --admin-user admin --admin-pass $defaultPassword --admin-email admin@example.com',
      generateCreateTestUserInstruction(),
      if (users != null) ...[
        for (final user in users) ...[
          generateCreateUserInstruction(user),
        ],
      ],
      if (apps != null) ...[
        for (final app in apps) ...[
          generateInstallAppInstruction(app),
        ],
      ],
      // Required to workaround restrictions for localhost and http only push proxies
      'RUN ./occ config:system:set allow_local_remote_servers --value=true',
      'RUN sed -i "s/localhost/host.docker.internal/" /usr/src/nextcloud/apps/notifications/lib/Controller/PushController.php',
      'ADD overlay /usr/src/nextcloud/',
      '',
    ];

    return instructions.join('\n');
  }

  static String generateFromNextcloudImageInstruction(
    final String nextcloudVersion,
  ) =>
      'FROM nextcloud:$nextcloudVersion';

  static String generateCreateTestUserInstruction() => generateCreateUserInstruction(
        TestNextcloudUser(
          defaultUsername,
          displayName: 'Test',
        ),
      );

  static String generateCreateUserInstruction(final TestNextcloudUser user) =>
      'RUN OC_PASS="$defaultPassword" ./occ user:add --password-from-env ${user.displayName != null ? '--display-name="${user.displayName}"' : ''} ${user.username}';

  static String generateInstallAppInstruction(
    final String appName,
  ) =>
      'RUN ./occ app:install $appName';
}

/// Validates that the response matches the schema
///
/// [cleanResponse] can be used for compatibility reasons, because some APIs are very inconsistent in their responses and don't populate all fields
Future<T?> validateResponse<T, U>(
  final ApiInstance api,
  final Future<Response> input, {
  final bool cleanResponse = false,
}) async {
  final response = await input;

  if (response.statusCode >= HttpStatus.badRequest) {
    throw ApiException(response.statusCode, await decodeBodyBytes(response));
  }
  if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
    var body = json.decode(await decodeBodyBytes(response));
    if (cleanResponse) {
      body = removeNulls(body);
    }
    var output = await api.apiClient.deserializeAsync(
      json.encode(body),
      T.toString(),
    );
    if (output is List) {
      output = output.map((final b) => b as U).toList();
    }
    output = output as T;

    var parsedBody = json.decode(json.encode(output));
    if (cleanResponse) {
      parsedBody = removeNulls(parsedBody);
    }
    expect(parsedBody, body);

    return output;
  }
  return null;
}

Map<String, dynamic> removeNullsFromMap(final Map<String, dynamic> json) => json
  ..removeWhere((final key, final value) => value == null)
  ..map<String, dynamic>((final key, final value) => MapEntry(key, removeNulls(value)));

List removeNullsFromList(final List list) => list
  ..removeWhere((final value) => value == null)
  ..map(removeNulls).toList();

T removeNulls<T>(final T e) =>
    ((e is List) ? removeNullsFromList(e) : (e is Map<String, dynamic> ? removeNullsFromMap(e) : e)) as T;

extension ListExtension on List {
  List removeNulls() => removeNullsFromList(this);
}

extension MapExtension on Map<String, dynamic> {
  Map removeNulls() => removeNullsFromMap(this);
}

int randomPort() => 1024 + Random().nextInt(65535 - 1024);

void expectDateInReasonableTimeRange(final DateTime actual, final DateTime expected) {
  const duration = Duration(seconds: 5);
  expect(actual.isAfter(expected.subtract(duration)), isTrue);
  expect(actual.isBefore(expected.add(duration)), isTrue);
}
