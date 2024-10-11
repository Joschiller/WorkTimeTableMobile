import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;
import 'package:work_time_table_mobile/models/event_setting/month_based_repetition_rule.dart';

extension MonthBasedRepetitionRuleMapper
    on prisma_model.MonthBasedRepetitionRule {
  MonthBasedRepetitionRule toAppModel() => MonthBasedRepetitionRule(
        repeatAfterMonths: repeatAfterMonths!,
        dayIndex: dayIndex!,
        weekIndex: weekIndex,
        countFromEnd: countFromEnd!,
      );
}
