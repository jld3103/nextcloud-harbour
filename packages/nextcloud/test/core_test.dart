import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud_test/nextcloud_test.dart';
import 'package:test/test.dart';

import 'helper.dart';

Future main() async {
  final dockerImageName = await TestHelper.prepareDockerImage(
    apps: [
      'news',
      'notes',
    ],
  );

  group('core', () {
    late TestNextcloudClient client;
    setUp(() async {
      client = await TestHelper.getPreparedClient(dockerImageName);
    });
    tearDown(() => client.destroy());

    test('Get status', () async {
      final status = (await validateResponse<CoreServerStatus, void>(
        client.core,
        client.core.getStatusWithHttpInfo(),
      ))!;
      expect(status.installed, true);
      expect(status.maintenance, false);
      expect(status.needsDbUpgrade, false);
      expect(status.version, startsWith(nextcloudVersion));
      expect(status.versionstring, startsWith('${nextcloudVersion.split('.')[0]}.'));
      expect(status.edition, '');
      expect(status.productname, 'Nextcloud');
      expect(status.extendedSupport, false);
    });

    test('Get capabilities', () async {
      final capabilities = (await validateResponse<CoreServerCapabilities, void>(
        client.core,
        client.core.getCapabilitiesWithHttpInfo(),
      ))!;
      expect(capabilities.ocs!.data!.version!.major.toString(), nextcloudVersion.split('.')[0]);
      expect(capabilities.ocs!.data!.version!.string, nextcloudVersion);
      expect(capabilities.ocs!.data!.capabilities!.theming!.name, 'Nextcloud');
      expect(capabilities.ocs!.data!.capabilities!.theming!.url, 'https://nextcloud.com');
      expect(capabilities.ocs!.data!.capabilities!.theming!.slogan, 'a safe home for all your data');
      expect(capabilities.ocs!.data!.capabilities!.theming!.color, '#0082c9');
      expect(capabilities.ocs!.data!.capabilities!.theming!.colorText, '#ffffff');
      expect(capabilities.ocs!.data!.capabilities!.theming!.logo, isNotEmpty);
      expect(capabilities.ocs!.data!.capabilities!.theming!.background, isNotEmpty);
      expect(capabilities.ocs!.data!.capabilities!.theming!.backgroundPlain, false);
      expect(capabilities.ocs!.data!.capabilities!.theming!.backgroundDefault, true);
      expect(capabilities.ocs!.data!.capabilities!.theming!.logoheader, isNotEmpty);
      expect(capabilities.ocs!.data!.capabilities!.theming!.favicon, isNotEmpty);
    });

    test('Get navigation apps', () async {
      final navigationApps = (await validateResponse<CoreNavigationApps, void>(
        client.core,
        client.core.getNavigationAppsWithHttpInfo(),
      ))!;
      expect(navigationApps.ocs!.data, hasLength(6));
      expect(navigationApps.ocs!.data[0].id, 'dashboard');
      expect(navigationApps.ocs!.data[1].id, 'files');
      expect(navigationApps.ocs!.data[2].id, 'photos');
      expect(navigationApps.ocs!.data[3].id, 'activity');
      expect(navigationApps.ocs!.data[4].id, 'notes');
      expect(navigationApps.ocs!.data[5].id, 'news');
    });
  });
}
