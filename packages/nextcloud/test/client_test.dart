import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud_test/nextcloud_test.dart';
import 'package:test/test.dart';

Future main() async {
  final dockerImageName = await TestHelper.prepareDockerImage();

  group('client', () {
    late TestNextcloudClient client;
    tearDown(() => client.destroy());

    test('User-Agent from AppType', () async {
      client = await TestHelper.getPreparedClient(
        dockerImageName,
        appType: AppType.nextcloud,
      );
      expect(client.userAgent, AppType.nextcloud.userAgent);
    });

    test('User-Agent with suffix', () async {
      client = await TestHelper.getPreparedClient(
        dockerImageName,
        userAgentOverride: 'test',
      );
      expect(client.userAgent, 'test');
    });
  });
}
