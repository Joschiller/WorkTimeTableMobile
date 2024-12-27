import 'package:flutter/material.dart';

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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                      '${duration < 0 ? '-' : ''}${(duration.abs() ~/ 60).toString().padLeft(2, '0')}:${(duration.abs() % 60).toString().padLeft(2, '0')} h'),
                ],
              ),
            ],
          ),
        ),
      );
}
