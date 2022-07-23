import 'dart:async';

import 'package:neon/src/apps/notifications/app.dart';
import 'package:neon/src/models/account.dart';
import 'package:neon/src/neon.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:rx_bloc/rx_bloc.dart';
import 'package:rxdart/rxdart.dart';

part 'notifications.rxb.g.dart';

abstract class NotificationsBlocEvents {
  void refresh();

  void deleteNotification(final NotificationsNotification notification);

  void deleteAllNotifications();
}

abstract class NotificationsBlocStates {
  BehaviorSubject<Result<List<NotificationsNotification>>> get notifications;

  Stream<Exception> get errors;
}

@RxBloc()
class NotificationsBloc extends $NotificationsBloc {
  NotificationsBloc(
    this.options,
    this.requestManager,
    this.client,
  ) {
    _$refreshEvent.listen((final _) => _loadNotifications());

    _$deleteNotificationEvent.listen((final notification) {
      _wrapAction(() async => client.notifications.deleteNotification(notification.notificationId!));
    });
    _$deleteAllNotificationsEvent.listen((final notification) {
      _wrapAction(() async => client.notifications.deleteAllNotifications());
    });

    _loadNotifications();
  }

  void _wrapAction(final Future Function() call) {
    final stream = requestManager.wrapWithoutCache(call).asBroadcastStream();
    stream.whereError().listen(_errorsStreamController.add);
    stream.whereSuccess().listen((final _) async {
      _loadNotifications();
    });
  }

  void _loadNotifications() {
    requestManager
        .wrapNextcloud<List<NotificationsNotification>, NotificationsListNotificationsResponse,
            NotificationsNotification, NextcloudNotificationsClient>(
          client.id,
          client.notifications,
          'notifications-notifications',
          () async => (await client.notifications.listNotifications())!,
          (final response) => response.ocs!.data,
          previousData: _notificationsSubject.valueOrNull?.data,
        )
        .listen(_notificationsSubject.add);
  }

  final NotificationsAppSpecificOptions options;
  final RequestManager requestManager;
  final NextcloudClient client;

  final _notificationsSubject = BehaviorSubject<Result<List<NotificationsNotification>>>();
  final _errorsStreamController = StreamController<Exception>();

  @override
  void dispose() {
    // ignore: discarded_futures
    _notificationsSubject.close();
    // ignore: discarded_futures
    _errorsStreamController.close();
    super.dispose();
  }

  @override
  BehaviorSubject<Result<List<NotificationsNotification>>> _mapToNotificationsState() => _notificationsSubject;

  @override
  Stream<Exception> _mapToErrorsState() => _errorsStreamController.stream.asBroadcastStream();
}
