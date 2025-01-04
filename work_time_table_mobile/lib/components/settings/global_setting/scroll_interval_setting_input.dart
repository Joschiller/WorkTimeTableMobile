import 'package:flutter/material.dart';

class ScrollIntervalSettingInput extends StatelessWidget {
  const ScrollIntervalSettingInput({
    super.key,
    required this.initialValue,
    required this.onChange,
    required this.onReset,
  });

  final String? initialValue;
  final void Function(String value) onChange;
  final void Function() onReset;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Scroll Interval:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: initialValue,
                onChanged: (String? value) {
                  if (value != null) {
                    onChange(value);
                  }
                },
                items: {'1', '5', '15', '20'}
                    .map<DropdownMenuItem<String>>(
                        (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                    .toList(),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onReset,
                icon: const Icon(Icons.undo),
              ),
            ],
          ),
          const Text(
            'The scroll interval is applied in time input views. Smaller intervals enable precise selections whilst larger intervals make the selection of the desired time value faster.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      );
}
