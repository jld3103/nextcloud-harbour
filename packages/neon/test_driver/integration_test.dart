import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:nextcloud_test/nextcloud_test.dart';

Future<void> main() async {
  final dockerImageName = await TestHelper.prepareDockerImage(apps: ['news', 'notes']);
  final client = await TestHelper.getPreparedClient(
    dockerImageName,
    useAppPassword: true,
  );

  try {
    await integrationDriver(
      onScreenshot: (final screenshotName, final screenshotBytes) async {
        final image = await File('screenshots/$screenshotName.png').create(recursive: true);
        image.writeAsBytesSync(screenshotBytes);
        return true;
      },
    );
  } catch (e) {
    // ignore: avoid_print
    print('Error occurred: $e');
  }
  await client.destroy();
}
