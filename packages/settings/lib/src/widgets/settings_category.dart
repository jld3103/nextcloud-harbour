part of '../../settings.dart';

class SettingsCategory extends StatelessWidget {
  const SettingsCategory({
    required this.tiles,
    this.title,
    super.key,
  });

  final Widget? title;
  final List<SettingsTile> tiles;

  @override
  Widget build(final BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            title!,
          ],
          ...tiles,
        ]
            .intersperse(
              const SizedBox(
                height: 10,
              ),
            )
            .toList(),
      );
}
