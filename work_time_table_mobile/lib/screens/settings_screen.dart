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
            ElevatedButton(
                onPressed: () => UserScreenRoute().push(context),
                child: const Text('User')),
            ElevatedButton(
                onPressed: () => WeekSettingScreenRoute().push(context),
                child: const Text('Week Settings')),
            ElevatedButton(
                onPressed: () => EventSettingScreenRoute().push(context),
                child: const Text('Event Settings')),
          ],
        ),
      );
}
