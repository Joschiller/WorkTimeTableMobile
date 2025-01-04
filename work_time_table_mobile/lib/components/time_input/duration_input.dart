import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:work_time_table_mobile/blocs/global_setting_cubit.dart';
import 'package:work_time_table_mobile/models/global_setting_key.dart';
import 'package:work_time_table_mobile/models/settings_map.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

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
            BlocSelector<GlobalSettingCubit, ContextDependentValue<SettingsMap>,
                int>(
              selector: (state) => runContextDependentAction(
                state,
                () => 5,
                (value) =>
                    int.tryParse(
                        value[GlobalSettingKey.scrollInterval] ?? '5') ??
                    5,
              ),
              builder: (context, scrollInterval) => NumberPicker(
                value: initialValue % 60,
                minValue: 0,
                maxValue: 59,
                step: scrollInterval,
                onChanged: (value) =>
                    _onChangeInBounds(((initialValue ~/ 60) * 60) + value),
                zeroPad: true,
                itemWidth: 40,
                itemHeight: 35,
              ),
            ),
            const Text('h'),
          ],
        ),
      );
}
