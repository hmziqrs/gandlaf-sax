import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandalf/constants.dart';
import 'package:gandalf/providers/app.dart';
import 'package:gandalf/screens/Home/events.dart';
import 'package:gandalf/services/analytics.dart';
import 'package:gandalf/widgets/Buttons/Alpha.dart';

class SheetControls extends ConsumerWidget {
  const SheetControls({Key? key}) : super(key: key);

  void _changeTheme(WidgetRef ref, dynamic mode) {
    final _mode = mode as ThemeMode;
    ref.read(appSettingsProvider.notifier).setThemeMode(_mode);

    Analytics.logEvent(
      ChangeThemeEvent(mode.toString().split('.').last),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> themeButtons = const [
      {
        'label': 'Light',
        'mode': ThemeMode.light,
        'icon': Icons.light_mode,
      },
      {
        'label': 'Dark',
        'mode': ThemeMode.dark,
        'icon': Icons.dark_mode,
      },
      {
        'label': 'System',
        'mode': ThemeMode.system,
        'icon': Icons.settings_brightness,
      },
    ];

    final appState = ref.watch(appSettingsProvider);
    final appController = ref.read(appSettingsProvider.notifier);
    final isNarrow = MediaQuery.of(context).size.width < 480;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PADDING * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Theme Selection
          Text(
            'Theme',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: PADDING),
          // Theme Buttons
          isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: themeButtons
                      .map((button) => Padding(
                            padding: EdgeInsets.only(bottom: PADDING),
                            child: AlphaButton(
                              label: button['label'],
                              onTap: () => _changeTheme(ref, button['mode']),
                              icon: button['icon'],
                              color: appState.themeMode == button['mode']
                                  ? primaryColor
                                  : null,
                            ),
                          ))
                      .toList(),
                )
              : Row(
                  children: themeButtons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final button = entry.value;

                    return Expanded(
                      child: AlphaButton(
                        label: button['label'],
                        onTap: () => _changeTheme(ref, button['mode']),
                        margin: EdgeInsets.only(
                          left: index == 0 ? 0 : PADDING,
                          right: index == themeButtons.length - 1 ? 0 : PADDING,
                        ),
                        icon: button['icon'],
                        color: appState.themeMode == button['mode']
                            ? primaryColor
                            : null,
                      ),
                    );
                  }).toList(),
                ),

          SizedBox(height: PADDING * 3),

          // Background Playback Toggle
          Row(
            children: [
              Expanded(
                child: Text(
                  'Background Playback',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Switch(
                value: appState.backgroundPlayback,
                onChanged: (value) {
                  appController.setBackgroundPlayback(
                    value,
                  );
                },
              ),
            ],
          ),
          SizedBox(height: PADDING * 1),
        ],
      ),
    );
  }
}
