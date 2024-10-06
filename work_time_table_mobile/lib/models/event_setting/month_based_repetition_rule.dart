import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;

class MonthBasedRepetitionRule {
  final int repeatAfterMonths;

  final int dayIndex;
  final int? weekIndex;
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
