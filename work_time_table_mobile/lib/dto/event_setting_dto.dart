import 'package:work_time_table_mobile/dto/day_based_repetition_rule_dto.dart';
import 'package:work_time_table_mobile/dto/month_based_repetition_rule_dto.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/event_type.dart';
import 'package:work_time_table_mobile/utils.dart';

class EventSettingDto {
  final int id;
  final EventType eventType;
  final String? title;

  final DateTime startDate;
  final DateTime endDate;

  final bool startIsHalfDay;
  final bool endIsHalfDay;

  final List<DayBasedRepetitionRuleDto> dayBasedRepetitionRules;
  final List<MonthBasedRepetitionRuleDto> monthBasedRepetitionRules;

  EventSettingDto({
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

  factory EventSettingDto.fromJson(Map<String, dynamic> json) =>
      EventSettingDto(
        id: json['id'],
        eventType:
            EventType.values.firstWhere((e) => e.name == json['eventType']),
        title: json['title'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        startIsHalfDay: json['startIsHalfDay'],
        endIsHalfDay: json['endIsHalfDay'],
        dayBasedRepetitionRules: (json['dayBasedRepetitionRules'] as List)
            .map((e) => DayBasedRepetitionRuleDto.fromJson(e))
            .toList(),
        monthBasedRepetitionRules: (json['monthBasedRepetitionRules'] as List)
            .map((e) => MonthBasedRepetitionRuleDto.fromJson(e))
            .toList(),
      );

  factory EventSettingDto.fromAppModel(EventSetting model) => EventSettingDto(
        id: model.id,
        eventType: model.eventType,
        title: model.title,
        startDate: model.startDate,
        endDate: model.endDate,
        startIsHalfDay: model.startIsHalfDay,
        endIsHalfDay: model.endIsHalfDay,
        dayBasedRepetitionRules: model.dayBasedRepetitionRules
            .map(DayBasedRepetitionRuleDto.fromAppModel)
            .toList(),
        monthBasedRepetitionRules: model.monthBasedRepetitionRules
            .map(MonthBasedRepetitionRuleDto.fromAppModel)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventType': eventType,
        'title': title,
        'startDate': technicalDateFormat.format(startDate),
        'endDate': technicalDateFormat.format(endDate),
        'startIsHalfDay': startIsHalfDay,
        'endIsHalfDay': endIsHalfDay,
        'dayBasedRepetitionRules': dayBasedRepetitionRules,
        'monthBasedRepetitionRules': monthBasedRepetitionRules,
      };

  EventSetting toAppModel() => EventSetting(
        id: id,
        eventType: eventType,
        title: title,
        startDate: startDate,
        endDate: endDate,
        startIsHalfDay: startIsHalfDay,
        endIsHalfDay: endIsHalfDay,
        dayBasedRepetitionRules:
            dayBasedRepetitionRules.map((e) => e.toAppModel()).toList(),
        monthBasedRepetitionRules:
            monthBasedRepetitionRules.map((e) => e.toAppModel()).toList(),
      );
}
