part of '../neon.dart';

class SettingsExportHelper {
  SettingsExportHelper({
    required this.globalOptions,
    required this.appImplementations,
    required this.accountSpecificOptions,
  });

  final GlobalOptions globalOptions;
  final List<AppImplementation> appImplementations;
  final Map<Account, List<Option>> accountSpecificOptions;

  Future applyFromJson(final Map<String, dynamic> data) async {
    final globalOptionsData = data['global'] as Map<String, dynamic>;
    await _applyOptionsMapToOptions(
      globalOptions.options,
      globalOptionsData,
    );

    final appImplementationsData = data['apps'] as Map<String, dynamic>;
    for (final appId in appImplementationsData.keys) {
      final matchingAppImplementations = appImplementations.where((final app) => app.id == appId).toList();
      if (matchingAppImplementations.length != 1) {
        return;
      }
      final appImplementationData = appImplementationsData[appId]! as Map<String, dynamic>;
      await _applyOptionsMapToOptions(
        matchingAppImplementations[0].options.options,
        appImplementationData,
      );
    }

    final accountsData = data['accounts'] as Map<String, dynamic>;
    for (final accountId in accountsData.keys) {
      final matchingAccounts = accountSpecificOptions.keys.where((final account) => account.id == accountId).toList();
      if (matchingAccounts.length != 1) {
        return;
      }
      final accountData = accountsData[accountId]! as Map<String, dynamic>;
      await _applyOptionsMapToOptions(
        accountSpecificOptions[matchingAccounts[0]]!,
        accountData,
      );
    }
  }

  Future _applyOptionsMapToOptions(final List<Option> options, final Map<String, dynamic> data) async {
    for (final optionKey in data.keys) {
      for (final option in options) {
        if (option.key == optionKey) {
          await option.set(await option.deserialize(data[optionKey]));
        }
      }
    }
  }

  Map<String, dynamic> toJsonExport() => {
        'global': {
          for (final option in globalOptions.options) ...{
            option.key: option.serialize(),
          },
        },
        'apps': {
          for (final appImplementation in appImplementations) ...{
            appImplementation.id: {
              for (final option in appImplementation.options.options) ...{
                option.key: option.serialize(),
              },
            },
          },
        },
        'accounts': {
          for (final account in accountSpecificOptions.keys) ...{
            account.id: {
              for (final option in accountSpecificOptions[account]!) ...{
                option.key: option.serialize(),
              },
            },
          },
        },
      };
}
