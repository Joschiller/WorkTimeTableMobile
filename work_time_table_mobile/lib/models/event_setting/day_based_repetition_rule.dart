import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;

class DayBasedRepetitionRule {
  final int repeatAfterDays;

  DayBasedRepetitionRule({required this.repeatAfterDays});
  DayBasedRepetitionRule.fromPrismaModel(
      prisma_model.DayBasedRepetitionRule rule)
      : this(
          repeatAfterDays: rule.repeatAfterDays!,
        );
}
