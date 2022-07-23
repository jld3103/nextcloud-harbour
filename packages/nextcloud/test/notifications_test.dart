import 'dart:async';

import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud_push_proxy/nextcloud_push_proxy.dart';
import 'package:nextcloud_test/nextcloud_test.dart';
import 'package:test/test.dart';

import 'helper.dart';

Future main() async {
  final dockerImageName = await TestHelper.prepareDockerImage();

  group('notifications', () {
    late TestNextcloudClient client;
    setUp(() async {
      client = await TestHelper.getPreparedClient(
        dockerImageName,
        username: 'admin',
      );
    });
    tearDown(() => client.destroy());

    Future sendTestNotification() async {
      await validateResponse<NotificationsEmptyResponse, void>(
        client.notifications,
        client.notifications.sendAdminNotificationWithHttpInfo(
          'admin',
          NotificationsAdminNotification(
            shortMessage: '123',
            longMessage: '456',
          ),
        ),
      );
    }

    test('Send admin notification', () async {
      await sendTestNotification();
    });

    test('List notifications', () async {
      await sendTestNotification();

      final startTime = DateTime.now().toUtc();
      final response = (await validateResponse<NotificationsListNotificationsResponse, void>(
        client.notifications,
        client.notifications.listNotificationsWithHttpInfo(),
      ))!;
      expect(response.ocs!.data, hasLength(1));
      expect(response.ocs!.data[0].notificationId, 1);
      expect(response.ocs!.data[0].app, 'admin_notifications');
      expect(response.ocs!.data[0].user, 'admin');
      expectDateInReasonableTimeRange(DateTime.parse(response.ocs!.data[0].datetime!), startTime);
      expect(response.ocs!.data[0].objectType, 'admin_notifications');
      expect(response.ocs!.data[0].objectId, isNotNull);
      expect(response.ocs!.data[0].subject, '123');
      expect(response.ocs!.data[0].message, '456');
      expect(response.ocs!.data[0].link, '');
      expect(response.ocs!.data[0].subjectRich, '');
      expect(response.ocs!.data[0].subjectRichParameters, hasLength(0));
      expect(response.ocs!.data[0].messageRich, '');
      expect(response.ocs!.data[0].messageRichParameters, hasLength(0));
      expect(response.ocs!.data[0].icon, isNotEmpty);
      expect(response.ocs!.data[0].actions, hasLength(0));
    });

    test('Get notification', () async {
      await sendTestNotification();

      final startTime = DateTime.now().toUtc();
      final response = (await validateResponse<NotificationsGetNotificationResponse, void>(
        client.notifications,
        client.notifications.getNotificationWithHttpInfo(1),
      ))!;
      expect(response.ocs!.data!.notificationId, 1);
      expect(response.ocs!.data!.app, 'admin_notifications');
      expect(response.ocs!.data!.user, 'admin');
      expectDateInReasonableTimeRange(DateTime.parse(response.ocs!.data!.datetime!), startTime);
      expect(response.ocs!.data!.objectType, 'admin_notifications');
      expect(response.ocs!.data!.objectId, isNotNull);
      expect(response.ocs!.data!.subject, '123');
      expect(response.ocs!.data!.message, '456');
      expect(response.ocs!.data!.link, '');
      expect(response.ocs!.data!.subjectRich, '');
      expect(response.ocs!.data!.subjectRichParameters, hasLength(0));
      expect(response.ocs!.data!.messageRich, '');
      expect(response.ocs!.data!.messageRichParameters, hasLength(0));
      expect(response.ocs!.data!.icon, isNotEmpty);
      expect(response.ocs!.data!.actions, hasLength(0));
    });

    test('Delete notification', () async {
      await sendTestNotification();
      await validateResponse<NotificationsEmptyResponse, void>(
        client.notifications,
        client.notifications.deleteNotificationWithHttpInfo(1),
      );

      final response = (await validateResponse<NotificationsListNotificationsResponse, void>(
        client.notifications,
        client.notifications.listNotificationsWithHttpInfo(),
      ))!;
      expect(response.ocs!.data, hasLength(0));
    });

    test('Delete all notifications', () async {
      await sendTestNotification();
      await sendTestNotification();
      await validateResponse<NotificationsEmptyResponse, void>(
        client.notifications,
        client.notifications.deleteAllNotificationsWithHttpInfo(),
      );

      final response = (await validateResponse<NotificationsListNotificationsResponse, void>(
        client.notifications,
        client.notifications.listNotificationsWithHttpInfo(),
      ))!;
      expect(response.ocs!.data, hasLength(0));
    });
  });

  group('push notifications', () {
    late TestNextcloudClient client;
    setUp(() async {
      client = await TestHelper.getPreparedClient(
        dockerImageName, username: 'admin', // We need to use app passwords in order to register push devices
        useAppPassword: true,
      );
    });
    tearDown(() => client.destroy());

    // The key size has to be 2048, other sizes are not accepted by Nextcloud (at the moment at least)
    // ignore: avoid_redundant_argument_values
    RSAKeypair generateKeypair() => RSAKeypair.fromRandom(keySize: 2048);

    test('Register device and receive notification', () async {
      const pushToken = '789';
      final port = randomPort();
      final keypair = generateKeypair();

      final pushProxy = NextcloudPushProxy();

      final subscription = (await client.notifications.registerDeviceAtServer(
        pushToken,
        keypair.publicKey,
        'http://host.docker.internal:$port/',
      ))!
          .ocs!
          .data!;
      expect(subscription.publicKey, hasLength(451));
      RSAPublicKey.fromPEM(subscription.publicKey!);
      expect(subscription.deviceIdentifier, isNotEmpty);
      expect(subscription.signature, isNotEmpty);

      final deviceCompleter = Completer();
      final notificationCompleter = Completer();

      await pushProxy.create(
        logging: false,
        port: port,
      );
      pushProxy.onNewDevice.listen((final device) async {
        expect(device.pushToken, pushToken);
        expect(device.deviceIdentifier, isNotEmpty);
        expect(device.deviceIdentifierSignature, isNotEmpty);
        expect(device.userPublicKey, isNotEmpty);

        deviceCompleter.complete();
      });
      pushProxy.onNewNotification.listen((final notification) async {
        expect(notification.deviceIdentifier, subscription.deviceIdentifier);
        expect(notification.pushTokenHash, generatePushTokenHash(pushToken));
        expect(notification.subject, isNotEmpty);
        expect(notification.signature, isNotEmpty);
        expect(notification.priority, 'normal');
        expect(notification.type, 'alert');

        final decryptedSubject = decryptPushNotificationSubject(keypair.privateKey, notification.subject);
        expect(decryptedSubject.nid, isNotNull);
        expect(decryptedSubject.app, 'admin_notifications');
        expect(decryptedSubject.subject, '123');
        expect(decryptedSubject.type, 'admin_notifications');
        expect(decryptedSubject.id, isNotEmpty);

        notificationCompleter.complete();
      });

      await client.notifications.registerDeviceAtPushProxy(
        pushToken,
        subscription,
        'http://localhost:$port/',
      );
      await client.notifications.sendAdminNotification(
        'admin',
        NotificationsAdminNotification(
          shortMessage: '123',
          longMessage: '456',
        ),
      );

      await deviceCompleter.future;
      await notificationCompleter.future;
      await pushProxy.close();
    });

    test('Remove push device', () async {
      await client.notifications.registerDeviceAtServer(
        '789',
        generateKeypair().publicKey,
        'https://example.com/',
      );

      await validateResponse<NotificationsEmptyResponse, void>(
        client.notifications,
        client.notifications.removeDeviceWithHttpInfo(),
      );
    });
  });
}
