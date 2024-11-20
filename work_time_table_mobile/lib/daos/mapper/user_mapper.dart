import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;
import 'package:work_time_table_mobile/daos/mapper/week_day_setting_mapper.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';

extension UserMapper on prisma_model.User {
  User toAppModel() => User(
        id: id!,
        name: name!,
      );
  WeekSetting toWeekSetting(
    Iterable<prisma_model.WeekDaySetting> weekDaySettings,
  ) =>
      WeekSetting(
        targetWorkTimePerWeek: targetWorkTimePerWeek!,
        weekDaySettings: {
          for (final setting in weekDaySettings)
            DayOfWeek.values.firstWhere((d) => d.name == setting.day):
                setting.toAppModel()
        },
      );
}
