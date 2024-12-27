import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/utils.dart';

class TimeInputSummary extends StatelessWidget {
  const TimeInputSummary({
    super.key,
    required this.label,
    required this.duration,
  });

  final String label;
  final int duration;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.grey.shade300,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(duration.timeString),
                ],
              ),
            ],
          ),
        ),
      );
}
