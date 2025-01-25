import 'package:work_time_table_mobile/models/event_setting/day_based_repetition_rule.dart';

class DayBasedRepetitionRuleDto {
  final int repeatAfterDays;

  DayBasedRepetitionRuleDto({required this.repeatAfterDays});

  factory DayBasedRepetitionRuleDto.fromJson(Map<String, dynamic> json) =>
      DayBasedRepetitionRuleDto(
        repeatAfterDays: json['repeatAfterDays'],
      );

  factory DayBasedRepetitionRuleDto.fromAppModel(
          DayBasedRepetitionRule model) =>
      DayBasedRepetitionRuleDto(
        repeatAfterDays: model.repeatAfterDays,
      );

  Map<String, dynamic> toJson() => {
        'repeatAfterDays': repeatAfterDays,
      };
}
