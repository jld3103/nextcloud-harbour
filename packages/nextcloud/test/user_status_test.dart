import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud_test/nextcloud_test.dart';
import 'package:test/test.dart';

import 'helper.dart';

Future main() async {
  final dockerImageName = await TestHelper.prepareDockerImage();

  group('user_status', () {
    late TestNextcloudClient client;
    setUp(() async {
      client = await TestHelper.getPreparedClient(dockerImageName);
    });
    tearDown(() => client.destroy());

    test('Find all predefined statuses', () async {
      final expectedStatusIDs = ['meeting', 'commuting', 'remote-work', 'sick-leave', 'vacationing'];
      final response = (await validateResponse<UserStatusPredefinedStatuses, void>(
        client.userStatus,
        client.userStatus.findAllPredefinedStatusesWithHttpInfo(),
      ))!;

      expect(response.ocs!.data, hasLength(5));
      final responseIDs = response.ocs!.data.map((final status) => status.id!);
      expect(expectedStatusIDs.map(responseIDs.contains).contains(false), false);
      for (final status in response.ocs!.data) {
        expect(status.icon, isNotNull);
        expect(status.message, isNotNull);
      }

      final meeting =
          UserStatusClearAt.fromJson(response.ocs!.data.singleWhere((final s) => s.id == 'meeting').clearAt!)!;
      expect(meeting.type, 'period');
      expect(meeting.time, 3600);

      final commuting =
          UserStatusClearAt.fromJson(response.ocs!.data.singleWhere((final s) => s.id == 'commuting').clearAt!)!;
      expect(commuting.type, 'period');
      expect(commuting.time, 1800);

      final remoteWork =
          UserStatusClearAt.fromJson(response.ocs!.data.singleWhere((final s) => s.id == 'remote-work').clearAt!)!;
      expect(remoteWork.type, 'end-of');
      expect(remoteWork.time, null);

      final sickLeave =
          UserStatusClearAt.fromJson(response.ocs!.data.singleWhere((final s) => s.id == 'sick-leave').clearAt!)!;
      expect(sickLeave.type, 'end-of');
      expect(sickLeave.time, null);

      expect(response.ocs!.data.singleWhere((final s) => s.id == 'vacationing').clearAt, null);
    });

    test('Set status', () async {
      final response = (await validateResponse<UserStatusGetUserStatus, void>(
        client.userStatus,
        client.userStatus.setStatusWithHttpInfo(UserStatusSetUserStatus(statusType: UserStatusTypeEnum.online)),
      ))!;

      expect(response.ocs!.data!.userId, 'test');
      expect(response.ocs!.data!.message, null);
      expect(response.ocs!.data!.messageId, null);
      expect(response.ocs!.data!.messageIsPredefined, false);
      expect(response.ocs!.data!.icon, null);
      expect(response.ocs!.data!.clearAt, null);
      expect(response.ocs!.data!.status, UserStatusTypeEnum.online);
      expect(response.ocs!.data!.statusIsUserDefined, true);
    });

    test('Get status', () async {
      // There seems to be a bug in Nextcloud which makes getting the status fail before it has been set once.
      // The error message from Nextcloud is "Could not create folder"

      await validateResponse<UserStatusGetUserStatus, void>(
        client.userStatus,
        client.userStatus.setStatusWithHttpInfo(UserStatusSetUserStatus(statusType: UserStatusTypeEnum.online)),
      );
      final response = (await validateResponse<UserStatusGetUserStatus, void>(
        client.userStatus,
        client.userStatus.getStatusWithHttpInfo(),
      ))!;

      expect(response.ocs!.data!.userId, 'test');
      expect(response.ocs!.data!.message, null);
      expect(response.ocs!.data!.messageId, null);
      expect(response.ocs!.data!.messageIsPredefined, false);
      expect(response.ocs!.data!.icon, null);
      expect(response.ocs!.data!.clearAt, null);
      expect(response.ocs!.data!.status, UserStatusTypeEnum.online);
      expect(response.ocs!.data!.statusIsUserDefined, true);
    });

    test('Find all statuses', () async {
      var response = (await validateResponse<UserStatusFindAllStatuses, void>(
        client.userStatus,
        client.userStatus.findAllStatusesWithHttpInfo(),
      ))!;
      expect(response.ocs!.data, hasLength(0));

      await validateResponse<UserStatusGetUserStatus, void>(
        client.userStatus,
        client.userStatus.setStatusWithHttpInfo(UserStatusSetUserStatus(statusType: UserStatusTypeEnum.online)),
      );

      response = (await validateResponse<UserStatusFindAllStatuses, void>(
        client.userStatus,
        client.userStatus.findAllStatusesWithHttpInfo(),
      ))!;
      expect(response.ocs!.data, hasLength(1));
      expect(response.ocs!.data[0].userId, 'test');
      expect(response.ocs!.data[0].message, null);
      expect(response.ocs!.data[0].icon, null);
      expect(response.ocs!.data[0].clearAt, null);
      expect(response.ocs!.data[0].status, UserStatusTypeEnum.online);
    });

    test('Find status', () async {
      // Same as getting status
      await validateResponse<UserStatusGetUserStatus, void>(
        client.userStatus,
        client.userStatus.setStatusWithHttpInfo(UserStatusSetUserStatus(statusType: UserStatusTypeEnum.online)),
      );

      final response = (await validateResponse<UserStatusFindStatus, void>(
        client.userStatus,
        client.userStatus.findStatusWithHttpInfo('test'),
      ))!;
      expect(response.ocs!.data!.userId, 'test');
      expect(response.ocs!.data!.message, null);
      expect(response.ocs!.data!.icon, null);
      expect(response.ocs!.data!.clearAt, null);
      expect(response.ocs!.data!.status, UserStatusTypeEnum.online);
    });

    test('Set predefined message', () async {
      final clearAt = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60;
      final response = (await validateResponse<UserStatusGetUserStatus, void>(
        client.userStatus,
        client.userStatus.setPredefinedMessageWithHttpInfo(
          UserStatusSetPredefinedMessage(
            messageId: 'meeting',
            clearAt: clearAt,
          ),
        ),
      ))!;

      expect(response.ocs!.data!.userId, 'test');
      expect(response.ocs!.data!.message, null);
      expect(response.ocs!.data!.messageId, 'meeting');
      expect(response.ocs!.data!.messageIsPredefined, true);
      expect(response.ocs!.data!.icon, null);
      expect(response.ocs!.data!.clearAt, clearAt);
      expect(response.ocs!.data!.status, UserStatusTypeEnum.offline);
      expect(response.ocs!.data!.statusIsUserDefined, false);
    });

    test('Set custom message', () async {
      final clearAt = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60;
      final response = (await validateResponse<UserStatusGetUserStatus, void>(
        client.userStatus,
        client.userStatus.setCustomMessageWithHttpInfo(
          UserStatusSetCustomMessage(
            statusIcon: '😀',
            message: 'bla',
            clearAt: clearAt,
          ),
        ),
      ))!;

      expect(response.ocs!.data!.userId, 'test');
      expect(response.ocs!.data!.message, 'bla');
      expect(response.ocs!.data!.messageId, null);
      expect(response.ocs!.data!.messageIsPredefined, false);
      expect(response.ocs!.data!.icon, '😀');
      expect(response.ocs!.data!.clearAt, clearAt);
      expect(response.ocs!.data!.status, UserStatusTypeEnum.offline);
      expect(response.ocs!.data!.statusIsUserDefined, false);
    });

    test('Clear message', () async {
      final clearAt = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60;
      await validateResponse<UserStatusGetUserStatus, void>(
        client.userStatus,
        client.userStatus.setCustomMessageWithHttpInfo(
          UserStatusSetCustomMessage(
            statusIcon: '😀',
            message: 'bla',
            clearAt: clearAt,
          ),
        ),
      );
      await client.userStatus.clearMessage();

      final response = (await validateResponse<UserStatusGetUserStatus, void>(
        client.userStatus,
        client.userStatus.getStatusWithHttpInfo(),
      ))!;
      expect(response.ocs!.data!.userId, 'test');
      expect(response.ocs!.data!.message, null);
      expect(response.ocs!.data!.messageId, null);
      expect(response.ocs!.data!.messageIsPredefined, false);
      expect(response.ocs!.data!.icon, null);
      expect(response.ocs!.data!.clearAt, null);
      expect(response.ocs!.data!.status, UserStatusTypeEnum.offline);
      expect(response.ocs!.data!.statusIsUserDefined, false);
    });

    test('Heartbeat', () async {
      await client.userStatus.heartbeat(UserStatusHeartbeat(status: UserStatusTypeEnum.online));
      final response = (await validateResponse<UserStatusGetUserStatus, void>(
        client.userStatus,
        client.userStatus.getStatusWithHttpInfo(),
      ))!;

      expect(response.ocs!.data!.userId, 'test');
      expect(response.ocs!.data!.message, null);
      expect(response.ocs!.data!.messageId, null);
      expect(response.ocs!.data!.messageIsPredefined, false);
      expect(response.ocs!.data!.icon, null);
      expect(response.ocs!.data!.clearAt, null);
      expect(response.ocs!.data!.status, UserStatusTypeEnum.online);
      expect(response.ocs!.data!.statusIsUserDefined, false);
    });
  });
}
