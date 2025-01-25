import 'package:work_time_table_mobile/dto/day_based_repetition_rule_dto.dart';
import 'package:work_time_table_mobile/dto/month_based_repetition_rule_dto.dart';
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
        eventType: json['eventType'],
        title: json['title'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        startIsHalfDay: json['startIsHalfDay'],
        endIsHalfDay: json['endIsHalfDay'],
        dayBasedRepetitionRules:
            (json['dayBasedRepetitionRules'] as List<Map<String, dynamic>>)
                .map(DayBasedRepetitionRuleDto.fromJson)
                .toList(),
        monthBasedRepetitionRules:
            (json['monthBasedRepetitionRules'] as List<Map<String, dynamic>>)
                .map(MonthBasedRepetitionRuleDto.fromJson)
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
        'dayBasedRepetitionRules':
            dayBasedRepetitionRules.map((e) => e.toJson()),
        'monthBasedRepetitionRules':
            monthBasedRepetitionRules.map((e) => e.toJson()),
      };
}
