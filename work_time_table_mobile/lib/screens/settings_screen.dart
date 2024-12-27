import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/page_template.dart';
import 'package:work_time_table_mobile/constants/routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => PageTemplate(
        title: 'Settings',
        content: Column(
          children: [
            Row(
              children: [
                Text(
                  'Configuration',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            Row(
              // TODO: mehr Metainformationen anzeigen
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => UserScreenRoute().push(context),
                    child: const Text('Users'),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => WeekSettingScreenRoute().push(context),
                    child: const Text('Week Settings'),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => EventSettingScreenRoute().push(context),
                    child: const Text('Event Settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
