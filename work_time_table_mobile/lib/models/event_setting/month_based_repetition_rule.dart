import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;

class MonthBasedRepetitionRule {
  final int repeatAfterMonths;

  /// Refers to day within the month if `weekIndex` is null - else refers to the day of week.
  final int dayIndex;
  final int? weekIndex;

  /// Refers to `dayIndex` if `weekIndex` is null - else refers to the `weekIndex`.
  final bool countFromEnd;

  MonthBasedRepetitionRule({
    required this.repeatAfterMonths,
    required this.dayIndex,
    required this.weekIndex,
    required this.countFromEnd,
  });
  MonthBasedRepetitionRule.fromPrismaModel(
      prisma_model.MonthBasedRepetitionRule rule)
      : this(
          repeatAfterMonths: rule.repeatAfterMonths!,
          dayIndex: rule.dayIndex!,
          weekIndex: rule.weekIndex,
          countFromEnd: rule.countFromEnd!,
        );
}
