import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:test/test.dart';

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

void expectDateInReasonableTimeRange(final DateTime actual, final DateTime expected) {
  const duration = Duration(seconds: 5);
  expect(actual.isAfter(expected.subtract(duration)), isTrue);
  expect(actual.isBefore(expected.add(duration)), isTrue);
}
