import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:neon/app.dart';
import 'package:neon/src/blocs/accounts.dart';
import 'package:neon/src/blocs/push_notifications.dart';
import 'package:neon/src/neon.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> Function() sharedPreferencesFactory = () async => SharedPreferences.getInstance();

Future main() async {
  Env? env;
  try {
    await dotenv.load(fileName: 'assets/.env');
    if (dotenv.env.keys.isNotEmpty) {
      if (kReleaseMode) {
        throw Exception('A release build can not contain a .env file');
      }
      env = Env.fromMap(dotenv.env);
    }
  } catch (e) {}

  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  await Global.init();

  final sharedPreferences = await sharedPreferencesFactory();

  final platform = await getNeonPlatform();
  final requestManager = await getRequestManager(platform);
  final allAppImplementations = getAppImplementations(sharedPreferences, requestManager, platform);

  final globalOptions = GlobalOptions(
    Storage('global', sharedPreferences),
  );

  final accountsBloc = AccountsBloc(
    requestManager,
    Storage('accounts', sharedPreferences),
    sharedPreferences,
    globalOptions,
  );
  final pushNotificationsBloc = PushNotificationsBloc(
    accountsBloc,
    sharedPreferences,
    globalOptions,
    env,
    platform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>(
          create: (final _) => sharedPreferences,
        ),
        Provider<Env?>(
          create: (final _) => env,
        ),
        Provider<NeonPlatform>(
          create: (final _) => platform,
        ),
        Provider<GlobalOptions>(
          create: (final _) => globalOptions,
        ),
        Provider<RequestManager>(
          create: (final _) => requestManager,
        ),
        Provider<AccountsBloc>(
          create: (final _) => accountsBloc,
        ),
        Provider<PushNotificationsBloc>(
          create: (final _) => pushNotificationsBloc,
        ),
        Provider<List<AppImplementation>>(
          create: (final _) => allAppImplementations,
        ),
      ],
      child: NeonApp(
        accountsBloc: accountsBloc,
        sharedPreferences: sharedPreferences,
        env: env,
        platform: platform,
        globalOptions: globalOptions,
      ),
    ),
  );
}
