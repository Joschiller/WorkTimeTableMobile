import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;
import 'package:work_time_table_mobile/daos/mapper/day_based_repetition_rule_mapper.dart';
import 'package:work_time_table_mobile/daos/mapper/month_based_repetition_rule_mapper.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/event_type.dart';

extension EventSettingMapper on prisma_model.EventSetting {
  EventSetting toAppModel() => EventSetting(
        id: id!,
        eventType: EventType.values.firstWhere((d) => d.name == type),
        title: title,
        startDate: startDate!,
        endDate: endDate!,
        startIsHalfDay: startIsHalfDay!,
        endIsHalfDay: endIsHalfDay!,
        dayBasedRepetitionRules:
            (dayBasedRepetitionRule ?? []).map((e) => e.toAppModel()).toList(),
        monthBasedRepetitionRules: (monthBasedRepetitionRule ?? [])
            .map((e) => e.toAppModel())
            .toList(),
      );
}
