import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud_test/nextcloud_test.dart';
import 'package:test/test.dart';

import 'helper.dart';

Future main() async {
  final dockerImageName = await TestHelper.prepareDockerImage();

  group('provisioning_api', () {
    late TestNextcloudClient client;
    setUp(() async {
      client = await TestHelper.getPreparedClient(dockerImageName);
    });
    tearDown(() => client.destroy());

    test('Get current user', () async {
      final user = (await validateResponse<ProvisioningApiUser, void>(
        client.provisioningApi,
        client.provisioningApi.getCurrentUserWithHttpInfo(),
        cleanResponse: true,
      ))!;
      expect(user.ocs!.data!.id, 'test');
      expect(user.ocs!.data!.getDisplayName(), 'Test');
      expect(user.ocs!.data!.displaynameScope, 'v2-federated');
      expect(user.ocs!.data!.language, 'en');
    });

    test('Get user by username', () async {
      final user = (await validateResponse<ProvisioningApiUser, void>(
        client.provisioningApi,
        client.provisioningApi.getUserWithHttpInfo('test'),
        cleanResponse: true,
      ))!;
      expect(user.ocs!.data!.id, 'test');
      expect(user.ocs!.data!.getDisplayName(), 'Test');
      expect(user.ocs!.data!.displaynameScope, 'v2-federated');
      expect(user.ocs!.data!.language, 'en');
    });
  });
}
