import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/page_template.dart';

class NotEnoughDataPage extends StatelessWidget {
  const NotEnoughDataPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => PageTemplate(
        title: title,
        content: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Not enough data',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Data for at least half a year is needed to provide statistics.',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
