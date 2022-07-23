part of '../../neon.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.account,
    required this.onThemeChanged,
    super.key,
  });

  final Account account;
  final Function(NextcloudTheme theme) onThemeChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

// ignore: prefer_mixin
class _HomePageState extends State<HomePage> with tray.TrayListener, WindowListener {
  final _appRegex = RegExp(r'^app_([a-z]+)$', multiLine: true);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late NeonPlatform _platform;
  late GlobalOptions _globalOptions;
  late RequestManager _requestManager;
  late CapabilitiesBloc _capabilitiesBloc;
  late AppsBloc _appsBloc;

  Rect? _lastBounds;

  @override
  void initState() {
    super.initState();

    _platform = Provider.of<NeonPlatform>(context, listen: false);
    _globalOptions = Provider.of<GlobalOptions>(context, listen: false);
    final accountsBloc = RxBlocProvider.of<AccountsBloc>(context);

    if (_platform.canUseSystemTray) {
      tray.trayManager.addListener(this);
    }
    if (_platform.canUseWindowManager) {
      windowManager.addListener(this);
    }

    _requestManager = Provider.of<RequestManager>(context, listen: false);
    _capabilitiesBloc = CapabilitiesBloc(
      _requestManager,
      widget.account.client,
    );
    _capabilitiesBloc.capabilities.listen((final result) {
      if (result.data != null) {
        widget.onThemeChanged(result.data!.theming!);
      }
    });
    _appsBloc = AppsBloc(
      _requestManager,
      accountsBloc,
      widget.account,
      Provider.of<List<AppImplementation>>(context, listen: false),
    );

    WidgetsBinding.instance.addPostFrameCallback((final _) async {
      final appImplementations = Provider.of<List<AppImplementation>>(context, listen: false);
      if (_platform.canUseQuickActions) {
        const quickActions = QuickActions();
        await quickActions.setShortcutItems(
          appImplementations
              .map(
                (final app) => ShortcutItem(
                  type: 'app_${app.id}',
                  localizedTitle: app.name(context),
                  icon: 'app_${app.id}',
                ),
              )
              .toList(),
        );
        await quickActions.initialize(_handleShortcut);
      }

      if (_platform.canUseWindowManager) {
        await windowManager.setPreventClose(true);

        if (_globalOptions.startupMinimized.value) {
          await _saveAndMinimizeWindow();
        }
      }

      if (_platform.canUseSystemTray) {
        _globalOptions.systemTrayEnabled.stream.listen((final enabled) async {
          if (enabled) {
            // TODO: This works on Linux, but maybe not on macOS or Windows
            await tray.trayManager.setIcon('assets/logo_neon.svg');
            if (mounted) {
              await tray.trayManager.setContextMenu(
                tray.Menu(
                  items: [
                    for (final app in appImplementations) ...[
                      tray.MenuItem(
                        key: 'app_${app.id}',
                        label: app.name(context),
                        // TODO: Add icons which should work on macOS and Windows
                      ),
                    ],
                    tray.MenuItem.separator(),
                    tray.MenuItem(
                      key: 'show_hide',
                      label: AppLocalizations.of(context).showSlashHide,
                    ),
                    tray.MenuItem(
                      key: 'exit',
                      label: AppLocalizations.of(context).exit,
                    ),
                  ],
                ),
              );
            }
          } else {
            await tray.trayManager.destroy();
          }
        });
      }

      Global.handleNotificationOpening = (final notification) async {
        final allAppImplementations = Provider.of<List<AppImplementation>>(context, listen: false);
        final matchingAppImplementations = allAppImplementations.where((final a) => a.id == notification.app);
        if (matchingAppImplementations.isNotEmpty) {
          _appsBloc.setActiveApp(notification.app!);
          return true;
        }

        return false;
      };

      if (_platform.canUsePushNotifications) {
        final localNotificationsPlugin = await PushUtils.initLocalNotifications();
        Global.onPushNotificationReceived = () async {
          final appImplementation = Provider.of<List<AppImplementation>>(context, listen: false)
              .singleWhere((final a) => a.id == 'notifications');
          _appsBloc.getAppBloc<NotificationsBloc>(appImplementation).refresh();
        };
        Global.onPushNotificationClicked = (final payload) async {
          if (payload != null) {
            final notification = NextcloudNotification.fromJson(json.decode(payload) as Map<String, dynamic>);
            debugPrint('onNotificationClicked: ${notification.subject}');

            final allAppImplementations = Provider.of<List<AppImplementation>>(context, listen: false);

            final matchingAppImplementations =
                allAppImplementations.where((final a) => a.id == notification.subject.app);

            late AppImplementation appImplementation;
            if (matchingAppImplementations.isNotEmpty) {
              appImplementation = matchingAppImplementations.single;
            } else {
              appImplementation = allAppImplementations.singleWhere((final a) => a.id == 'notifications');
            }

            if (appImplementation.id != 'notifications') {
              _appsBloc.getAppBloc<NotificationsBloc>(appImplementation).deleteNotification(
                    NotificationsNotification(
                      notificationId: notification.subject.nid,
                    ),
                  );
            }
            await _openAppFromExternal(appImplementation.id);
          }
        };

        final details = await localNotificationsPlugin.getNotificationAppLaunchDetails();
        if (details != null && details.didNotificationLaunchApp) {
          await Global.onPushNotificationClicked!(details.payload);
        }
      }
    });
  }

  @override
  void onTrayMenuItemClick(tray.MenuItem menuItem) {
    if (menuItem.key != null) {
      _handleShortcut(menuItem.key!);
    }
  }

  @override
  Future onWindowClose() async {
    if (_globalOptions.startupMinimizeInsteadOfExit.value) {
      await _saveAndMinimizeWindow();
    } else {
      await windowManager.destroy();
    }
  }

  Future _handleShortcut(final String shortcutType) async {
    if (shortcutType == 'show_hide') {
      if (_platform.canUseWindowManager) {
        if (await windowManager.isVisible()) {
          await _saveAndMinimizeWindow();
        } else {
          await _showAndRestoreWindow();
        }
      }
      return;
    }
    if (shortcutType == 'exit') {
      exit(0);
    }

    final matches = _appRegex.allMatches(shortcutType).toList();
    if (matches.isNotEmpty) {
      await _openAppFromExternal(matches[0].group(1)!);
      return;
    }
  }

  Future _openAppFromExternal(final String id) async {
    _appsBloc.setActiveApp(id);
    Navigator.of(context).popUntil((final route) => route.settings.name == 'home');
    if (_platform.canUseWindowManager) {
      await _showAndRestoreWindow();
    }
  }

  Future _saveAndMinimizeWindow() async {
    _lastBounds = await windowManager.getBounds();
    if (_globalOptions.systemTrayEnabled.value && _globalOptions.systemTrayHideToTrayWhenMinimized.value) {
      await windowManager.hide();
    } else {
      await windowManager.minimize();
    }
  }

  Future _showAndRestoreWindow() async {
    final wasVisible = await windowManager.isVisible();
    await windowManager.show();
    await windowManager.focus();
    if (_lastBounds != null && !wasVisible) {
      await windowManager.setBounds(_lastBounds);
    }
  }

  @override
  void dispose() {
    _capabilitiesBloc.dispose();
    _appsBloc.dispose();

    if (_platform.canUseSystemTray) {
      tray.trayManager.removeListener(this);
    }
    if (_platform.canUseWindowManager) {
      windowManager.removeListener(this);
    }

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final accountsBloc = RxBlocProvider.of<AccountsBloc>(context);
    return StandardRxResultBuilder<CapabilitiesBloc, Capabilities>(
      bloc: _capabilitiesBloc,
      state: (final bloc) => bloc.capabilities,
      builder: (
        final context,
        final capabilitiesData,
        final capabilitiesError,
        final capabilitiesLoading,
        final _,
      ) =>
          StandardRxResultBuilder<AppsBloc, List<AppImplementation>>(
        bloc: _appsBloc,
        state: (final bloc) => bloc.appImplementations,
        builder: (
          final context,
          final appsData,
          final appsError,
          final appsLoading,
          final _,
        ) =>
            RxBlocBuilder<AppsBloc, String?>(
          bloc: _appsBloc,
          state: (final bloc) => bloc.activeAppID,
          builder: (
            final context,
            final activeAppIDSnapshot,
            final _,
          ) =>
              RxBlocBuilder<AccountsBloc, List<Account>>(
            bloc: accountsBloc,
            state: (final bloc) => bloc.accounts,
            builder: (
              final context,
              final accountsSnapshot,
              final _,
            ) =>
                WillPopScope(
              onWillPop: () async {
                if (_scaffoldKey.currentState!.isDrawerOpen) {
                  Navigator.pop(context);
                  return true;
                }

                _scaffoldKey.currentState!.openDrawer();
                return false;
              },
              child: Scaffold(
                key: _scaffoldKey,
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  title: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (appsData != null && activeAppIDSnapshot.hasData) ...[
                              Flexible(
                                child: Text(
                                  appsData.singleWhere((final a) => a.id == activeAppIDSnapshot.data!).name(context),
                                ),
                              ),
                            ],
                            if (appsError != null) ...[
                              const SizedBox(
                                width: 8,
                              ),
                              Icon(
                                Icons.error_outline,
                                size: 30,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ],
                            if (appsLoading) ...[
                              const SizedBox(
                                width: 8,
                              ),
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
                            const SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (appsData != null && activeAppIDSnapshot.hasData) ...[
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (final context) => NextcloudAppSpecificSettingsPage(
                                      appImplementation:
                                          appsData.singleWhere((final a) => a.id == activeAppIDSnapshot.data!),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Builder(
                              builder: (final context) {
                                if (accountsSnapshot.hasData) {
                                  final matches = accountsSnapshot.data!
                                      .where(
                                        (final account) => account.id == widget.account.id,
                                      )
                                      .toList();
                                  if (matches.length == 1) {
                                    return AccountAvatar(
                                      account: matches[0],
                                      requestManager: _requestManager,
                                    );
                                  }
                                }
                                return Container();
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                drawer: Drawer(
                  child: Column(
                    children: [
                      Expanded(
                        child: Scrollbar(
                          child: ListView(
                            // Needed for the drawer header to also render in the statusbar
                            padding: EdgeInsets.zero,
                            children: [
                              Builder(
                                builder: (final context) {
                                  if (accountsSnapshot.hasData) {
                                    return DrawerHeader(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (capabilitiesData != null) ...[
                                            Text(
                                              capabilitiesData.theming!.name!,
                                              style: DefaultTextStyle.of(context).style.copyWith(
                                                    color: Theme.of(context).colorScheme.onPrimary,
                                                  ),
                                            ),
                                            if (capabilitiesData.theming!.logo != null) ...[
                                              Flexible(
                                                child: CachedURLImage(
                                                  url: capabilitiesData.theming!.logo!,
                                                  requestManager: _requestManager,
                                                  client: widget.account.client,
                                                ),
                                              ),
                                            ],
                                          ] else ...[
                                            Container(),
                                          ],
                                          if (accountsSnapshot.data!.length != 1) ...[
                                            DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                dropdownColor: Theme.of(context).colorScheme.primary,
                                                iconEnabledColor: Theme.of(context).colorScheme.onPrimary,
                                                value: widget.account.id,
                                                items: accountsSnapshot.data!
                                                    .map<DropdownMenuItem<String>>(
                                                      (final account) => DropdownMenuItem<String>(
                                                        value: account.id,
                                                        child: AccountTile(
                                                          account: account,
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (final id) {
                                                  for (final account in accountsSnapshot.data!) {
                                                    if (account.id == id) {
                                                      accountsBloc.setActiveAccount(account);
                                                      break;
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              ),
                              ExceptionWidget(
                                appsError,
                                onRetry: () {
                                  _appsBloc.refresh();
                                },
                              ),
                              CustomLinearProgressIndicator(
                                visible: appsLoading,
                              ),
                              if (appsData != null) ...[
                                for (final appImplementation in appsData) ...[
                                  if (appsData.map((final a) => a.id).contains(appImplementation.id)) ...[
                                    ListTile(
                                      title: Text(appImplementation.name(context)),
                                      leading: appImplementation.buildIcon(context),
                                      minLeadingWidth: 0,
                                      onTap: () {
                                        _appsBloc.setActiveApp(appImplementation.id);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context).settings),
                        leading: const Icon(Icons.settings),
                        minLeadingWidth: 0,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (final context) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                body: Column(
                  children: [
                    ServerStatus(
                      account: widget.account,
                    ),
                    ExceptionWidget(
                      appsError,
                      onRetry: () {
                        _appsBloc.refresh();
                      },
                    ),
                    if (appsData != null) ...[
                      if (appsData.isEmpty) ...[
                        Expanded(
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context).errorNoCompatibleNextcloudAppsFound,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ] else ...[
                        if (activeAppIDSnapshot.hasData) ...[
                          Expanded(
                            child: appsData
                                .singleWhere((final a) => a.id == activeAppIDSnapshot.data!)
                                .buildPage(context, _appsBloc),
                          ),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
