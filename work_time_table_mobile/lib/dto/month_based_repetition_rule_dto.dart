import 'package:work_time_table_mobile/models/event_setting/month_based_repetition_rule.dart';

class MonthBasedRepetitionRuleDto {
  final int repeatAfterMonths;
  final int dayIndex;
  final int? weekIndex;
  final bool countFromEnd;

  MonthBasedRepetitionRuleDto({
    required this.repeatAfterMonths,
    required this.dayIndex,
    required this.weekIndex,
    required this.countFromEnd,
  });

  factory MonthBasedRepetitionRuleDto.fromJson(Map<String, dynamic> json) =>
      MonthBasedRepetitionRuleDto(
        repeatAfterMonths: json['repeatAfterMonths'],
        dayIndex: json['dayIndex'],
        weekIndex: json['weekIndex'],
        countFromEnd: json['countFromEnd'],
      );

  factory MonthBasedRepetitionRuleDto.fromAppModel(
          MonthBasedRepetitionRule model) =>
      MonthBasedRepetitionRuleDto(
        repeatAfterMonths: model.repeatAfterMonths,
        dayIndex: model.monthBasedRepetitionRuleBase.dayIndex,
        weekIndex: model.monthBasedRepetitionRuleBase.weekIndex,
        countFromEnd: model.monthBasedRepetitionRuleBase.countFromEnd,
      );

  Map<String, dynamic> toJson() => {
        'repeatAfterMonths': repeatAfterMonths,
        'dayIndex': dayIndex,
        'weekIndex': weekIndex,
        'countFromEnd': countFromEnd,
      };

  MonthBasedRepetitionRule toAppModel() => MonthBasedRepetitionRule(
        repeatAfterMonths: repeatAfterMonths,
        monthBasedRepetitionRuleBase: MonthBasedRepetitionRuleBase(
          dayIndex: dayIndex,
          weekIndex: weekIndex,
          countFromEnd: countFromEnd,
        ),
      );
}
