import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';

class MonthBasedRepetitionRule {
  final int repeatAfterMonths;
  final MonthBasedRepetitionRuleBase monthBasedRepetitionRuleBase;

  MonthBasedRepetitionRule({
    required this.repeatAfterMonths,
    required this.monthBasedRepetitionRuleBase,
  });

  String toDisplayString() => monthBasedRepetitionRuleBase.toDisplayString();

  @override
  int get hashCode =>
      monthBasedRepetitionRuleBase.hashCode +
      (monthBasedRepetitionRuleBase.countFromEnd ? -1000 : 1000) *
          repeatAfterMonths;

  @override
  bool operator ==(Object other) =>
      (other is MonthBasedRepetitionRuleBase &&
          monthBasedRepetitionRuleBase == other) ||
      (other is MonthBasedRepetitionRule &&
          repeatAfterMonths == other.repeatAfterMonths &&
          monthBasedRepetitionRuleBase == other.monthBasedRepetitionRuleBase);

  MonthBasedRepetitionRule withRepeatAfterMonths(int repeatAfterMonths) =>
      MonthBasedRepetitionRule(
        repeatAfterMonths: repeatAfterMonths,
        monthBasedRepetitionRuleBase: monthBasedRepetitionRuleBase,
      );
}

class MonthBasedRepetitionRuleBase {
  /// Refers to day within the month if `weekIndex` is null - else refers to the day of week.
  final int dayIndex;
  final int? weekIndex;

  /// Refers to `dayIndex` if `weekIndex` is null - else refers to the `weekIndex`.
  final bool countFromEnd;

  MonthBasedRepetitionRuleBase({
    required this.dayIndex,
    required this.weekIndex,
    required this.countFromEnd,
  });

  String toDisplayString() => (weekIndex != null)
      ? countFromEnd
          ? '${weekIndex! > 0 ? '$weekIndex. to ' : ''}last ${DayOfWeek.values[dayIndex].name} in month'
          : '${weekIndex! + 1}. ${DayOfWeek.values[dayIndex].name} in month'
      : countFromEnd
          ? '${dayIndex > 0 ? '$dayIndex. to ' : ''}last day of month'
          : '${dayIndex + 1}. day of month';

  @override
  int get hashCode =>
      (dayIndex + 100 * (weekIndex ?? 5)) * (countFromEnd ? -1 : 1);

  @override
  bool operator ==(Object other) =>
      (other is MonthBasedRepetitionRuleBase &&
          dayIndex == other.dayIndex &&
          weekIndex == other.weekIndex &&
          countFromEnd == other.countFromEnd) ||
      (other is MonthBasedRepetitionRule &&
          this == other.monthBasedRepetitionRuleBase);

  MonthBasedRepetitionRule withRepeatAfterMonths(int repeatAfterMonths) =>
      MonthBasedRepetitionRule(
        repeatAfterMonths: repeatAfterMonths,
        monthBasedRepetitionRuleBase: this,
      );
}
