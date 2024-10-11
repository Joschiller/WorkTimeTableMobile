import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;
import 'package:work_time_table_mobile/models/value/week_value.dart';

extension WeekValueMapper on prisma_model.WeekValue {
  WeekValue toAppModel() => WeekValue(
        weekStartDate: weekStartDate!,
        targetTime: targetTime!,
      );
}
