import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;
import 'package:work_time_table_mobile/models/event_setting/day_based_repetition_rule.dart';
import 'package:work_time_table_mobile/models/event_setting/month_based_repetition_rule.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/identifiable.dart';
import 'package:work_time_table_mobile/models/event_setting/event_type.dart';

class EventSetting implements Identifiable {
  final int id;
  final EventType eventType;
  final String? title;

  final DateTime startDate;
  final DateTime endDate;
  final bool startIsHalfDay;
  final bool endIsHalfDay;

  final List<DayBasedRepetitionRule> dayBasedRepetitionRules;
  final List<MonthBasedRepetitionRule> monthBasedRepetitionRules;

  EventSetting({
    required this.id,
    required this.eventType,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.startIsHalfDay,
    required this.endIsHalfDay,
    required this.dayBasedRepetitionRules,
    required this.monthBasedRepetitionRules,
  });
  EventSetting.fromPrismaModel(prisma_model.EventSetting eventSetting)
      : this(
          id: eventSetting.id!,
          eventType:
              EventType.values.firstWhere((d) => d.name == eventSetting.type),
          title: eventSetting.title,
          startDate: eventSetting.startDate!,
          endDate: eventSetting.endDate!,
          startIsHalfDay: eventSetting.startIsHalfDay!,
          endIsHalfDay: eventSetting.endIsHalfDay!,
          dayBasedRepetitionRules: (eventSetting.dayBasedRepetitionRule ?? [])
              .map(DayBasedRepetitionRule.fromPrismaModel)
              .toList(),
          monthBasedRepetitionRules:
              (eventSetting.monthBasedRepetitionRule ?? [])
                  .map(MonthBasedRepetitionRule.fromPrismaModel)
                  .toList(),
        );

  @override
  get identity => id;
}
