part of '../neon.dart';

abstract class NextcloudAppSpecificOptions {
  NextcloudAppSpecificOptions(this.storage);

  final Storage storage;
  late final List<OptionsCategory> categories;
  late final List<Option> options;

  void dispose() {
    for (final option in options) {
      option.dispose();
    }
  }
}
