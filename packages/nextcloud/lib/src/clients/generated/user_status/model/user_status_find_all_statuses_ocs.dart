//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UserStatusFindAllStatusesOcs {
  /// Returns a new [UserStatusFindAllStatusesOcs] instance.
  UserStatusFindAllStatusesOcs({
    this.meta,
    this.data = const [],
  });

  /// Stub
  Object? meta;

  List<UserStatusPublicUserStatus> data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserStatusFindAllStatusesOcs && other.meta == meta && other.data == data;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (meta == null ? 0 : meta!.hashCode) + (data.hashCode);

  @override
  String toString() => 'UserStatusFindAllStatusesOcs[meta=$meta, data=$data]';

  Map<String, dynamic> toJson() {
    final _json = <String, dynamic>{};
    if (meta != null) {
      _json[r'meta'] = meta;
    } else {
      _json[r'meta'] = null;
    }
    _json[r'data'] = data;
    return _json;
  }

  /// Returns a new [UserStatusFindAllStatusesOcs] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UserStatusFindAllStatusesOcs? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UserStatusFindAllStatusesOcs[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UserStatusFindAllStatusesOcs[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UserStatusFindAllStatusesOcs(
        meta: mapValueOfType<Object>(json, r'meta'),
        data: UserStatusPublicUserStatus.listFromJson(json[r'data']) ?? const [],
      );
    }
    return null;
  }

  static List<UserStatusFindAllStatusesOcs>? listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <UserStatusFindAllStatusesOcs>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UserStatusFindAllStatusesOcs.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UserStatusFindAllStatusesOcs> mapFromJson(dynamic json) {
    final map = <String, UserStatusFindAllStatusesOcs>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UserStatusFindAllStatusesOcs.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UserStatusFindAllStatusesOcs-objects as value to a dart map
  static Map<String, List<UserStatusFindAllStatusesOcs>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<UserStatusFindAllStatusesOcs>>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UserStatusFindAllStatusesOcs.listFromJson(
          entry.value,
          growable: growable,
        );
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{};
}
