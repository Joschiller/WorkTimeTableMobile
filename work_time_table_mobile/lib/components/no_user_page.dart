import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/page_template.dart';
import 'package:work_time_table_mobile/constants/routes.dart';

class NoUserPage extends StatelessWidget {
  const NoUserPage({
    super.key,
    required this.title,
    this.menuButtons,
  });

  final String title;
  final List<({Icon icon, void Function() onPressed})>? menuButtons;

  @override
  Widget build(BuildContext context) => PageTemplate(
        title: title,
        menuButtons: menuButtons,
        content: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No user selected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Go to the settings to configure a user.'),
                  GestureDetector(
                    onTap: () => UserScreenForCreationRoute().push(context),
                    child: Text(
                      'Add first user',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
}
