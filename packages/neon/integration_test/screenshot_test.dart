import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:neon/main.dart';
import 'package:neon/src/neon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCache implements Cache {
  final _data = <String, String>{};

  @override
  Future init() async {}

  @override
  Future<String?> get(String key) async => _data[key];

  @override
  Future<bool> has(String key) async => _data[key] != null;

  @override
  Future set(String key, String value) async => _data[key] = value;
}

class MockSharedPreferences implements SharedPreferences {
  final _data = <String, dynamic>{};

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<bool> commit() async => true;

  @override
  Future reload() async {}

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Set<String> getKeys() => _data.keys.toSet();

  @override
  bool containsKey(String key) => _data.keys.contains(key);

  @override
  Object? get(String key) => _data[key];

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  double? getDouble(String key) => _data[key] as double?;

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  List<String>? getStringList(String key) => (_data[key] as List).cast<String>();

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }
}

Future screenshot(
  final IntegrationTestWidgetsFlutterBinding binding,
  final WidgetTester tester,
  final String name,
) async {
  if (Platform.isAndroid) {
    await binding.convertFlutterSurfaceToImage();
  }

  await tester.pumpAndSettle();

  await binding.takeScreenshot(name);
}

Widget testApp({
  required final Widget child,
  final Brightness brightness = Brightness.light,
  final bool oledAsDark = true,
}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: getThemeFromNextcloudTheme(
        null,
        ThemeMode.system,
        brightness,
        oledAsDark: oledAsDark,
      ),
      home: child,
    );

Future main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    cacheFactory = (final platform) => MockCache();
    sharedPreferencesFactory = () async => MockSharedPreferences();
  });

  testWidgets('screenshot', (final tester) async {
    await tester.pumpWidget(
      testApp(
        child: HomePage(
          account: Account(
            serverURL: '',
            username: '',
          ),
          onThemeChanged: (final _) {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    await screenshot(binding, tester, 'bla');
  });
}
