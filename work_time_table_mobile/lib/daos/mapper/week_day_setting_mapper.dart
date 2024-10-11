import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_day_setting.dart';

extension WeekDaySettingMapper on prisma_model.WeekDaySetting {
  WeekDaySetting toAppModel() => WeekDaySetting(
        dayOfWeek: DayOfWeek.values.firstWhere((d) => d.name == day),
        defaultWorkTimeStart: defaultWorkTimeStart,
        defaultWorkTimeEnd: defaultWorkTimeEnd,
        mandatoryWorkTimeStart: mandatoryWorkTimeStart,
        mandatoryWorkTimeEnd: mandatoryWorkTimeEnd,
        defaultBreakDuration: defaultBreakDuration,
        timeEquivalent: timeEquivalent!,
      );
}
