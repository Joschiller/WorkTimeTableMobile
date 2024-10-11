import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;
import 'package:work_time_table_mobile/models/value/day_mode.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';

extension DayValueMapper on prisma_model.DayValue {
  DayValue toAppModel() => DayValue(
        date: date!,
        mode: DayMode.values.firstWhere((d) => d.name == mode),
        workTimeStart: workTimeStart!,
        workTimeEnd: workTimeEnd!,
        breakDuration: breakDuration!,
      );
}
