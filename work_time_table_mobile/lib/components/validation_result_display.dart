import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/app_error.dart';

class ValidationResultDisplay extends StatelessWidget {
  const ValidationResultDisplay({
    super.key,
    required this.handledErrors,
    required this.occurredErrors,
  });

  final List<AppError> handledErrors;
  final List<AppError> occurredErrors;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: handledErrors
            .map((error) => Row(
                  children: [
                    occurredErrors.contains(error)
                        ? Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          )
                        : const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                    const SizedBox(width: 8),
                    Wrap(
                      children: [
                        Text(
                          error.displayText,
                          style: TextStyle(
                            color: occurredErrors.contains(error)
                                ? Theme.of(context).colorScheme.error
                                : Colors.green,
                          ),
                        ),
                      ],
                    )
                  ],
                ))
            .toList(),
      );
}
