import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:neon/l10n/localizations.dart';
import 'package:neon/src/blocs/accounts.dart';
import 'package:neon/src/blocs/capabilities.dart';
import 'package:neon/src/neon.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NeonApp extends StatefulWidget {
  const NeonApp({
    required this.accountsBloc,
    required this.sharedPreferences,
    required this.env,
    required this.platform,
    required this.globalOptions,
    super.key,
  });

  final AccountsBloc accountsBloc;
  final SharedPreferences sharedPreferences;
  final Env? env;
  final NeonPlatform platform;
  final GlobalOptions globalOptions;

  @override
  State<NeonApp> createState() => _NeonAppState();
}

// ignore: prefer_mixin
class _NeonAppState extends State<NeonApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  NextcloudTheme? _userTheme;
  final _platformBrightness = BehaviorSubject<Brightness>.seeded(
    WidgetsBinding.instance.window.platformBrightness,
  );

  @override
  void didChangePlatformBrightness() {
    _platformBrightness.add(WidgetsBinding.instance.window.platformBrightness);

    super.didChangePlatformBrightness();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((final _) {
      widget.accountsBloc.activeAccount.listen((final activeAccount) async {
        FlutterNativeSplash.remove();

        if (activeAccount == null) {
          await _navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (final context) => const LoginPage(),
            ),
            (final _) => false,
          );
        } else {
          await _navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              settings: const RouteSettings(
                name: 'home',
              ),
              builder: (final context) => HomePage(
                account: activeAccount,
                onThemeChanged: (final theme) {
                  setState(() {
                    _userTheme = theme;
                  });
                },
              ),
            ),
            (final _) => false,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // ignore: discarded_futures
    _platformBrightness.close();

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => StreamBuilder<Brightness>(
        stream: _platformBrightness,
        builder: (final context, final platformBrightnessSnapshot) => StreamBuilder<ThemeMode>(
          stream: widget.globalOptions.themeMode.stream,
          builder: (final context, final themeModeSnapshot) => StreamBuilder<bool>(
            stream: widget.globalOptions.themeOLEDAsDark.stream,
            builder: (final context, final themeOLEDAsDarkSnapshot) {
              if (!platformBrightnessSnapshot.hasData ||
                  !themeOLEDAsDarkSnapshot.hasData ||
                  !themeModeSnapshot.hasData) {
                return Container();
              }
              return MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                navigatorKey: _navigatorKey,
                theme: getThemeFromNextcloudTheme(
                  _userTheme,
                  themeModeSnapshot.data!,
                  platformBrightnessSnapshot.data!,
                  oledAsDark: themeOLEDAsDarkSnapshot.data!,
                ),
                home: Container(),
              );
            },
          ),
        ),
      );
}
