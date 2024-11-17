import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class DurationInput extends StatelessWidget {
  const DurationInput({
    super.key,
    int? value,
    int? min,
    int? max,
    required this.onChange,
  })  : initialValue = value ?? 0,
        min = min ?? 0,
        max = max ?? 99 * 60;

  final int initialValue;
  final int min;
  final int max;
  final void Function(int value) onChange;

  void _onChangeInBounds(int value) => onChange(value < min
      ? min
      : value > max
          ? max
          : value);

  @override
  Widget build(BuildContext context) => Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NumberPicker(
              value: initialValue ~/ 60,
              minValue: (min / 60).floor(),
              maxValue: (max / 60).ceil(),
              onChanged: (value) =>
                  _onChangeInBounds((value * 60) + (initialValue % 60)),
              zeroPad: true,
              itemWidth: 40,
              itemHeight: 35,
            ),
            const Text(':'),
            NumberPicker(
              value: initialValue % 60,
              minValue: 0,
              maxValue: 59,
              onChanged: (value) =>
                  _onChangeInBounds(((initialValue ~/ 60) * 60) + value),
              zeroPad: true,
              itemWidth: 40,
              itemHeight: 35,
            ),
            const Text('h'),
          ],
        ),
      );
}
