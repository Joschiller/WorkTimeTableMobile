import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;
import 'package:work_time_table_mobile/models/event_setting/day_based_repetition_rule.dart';

extension DayBasedRepetitionRuleMapper on prisma_model.DayBasedRepetitionRule {
  DayBasedRepetitionRule toAppModel() => DayBasedRepetitionRule(
        repeatAfterDays: repeatAfterDays!,
      );
}
