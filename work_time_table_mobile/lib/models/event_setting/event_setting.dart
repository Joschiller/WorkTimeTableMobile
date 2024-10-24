import 'package:work_time_table_mobile/models/event_setting/day_based_repetition_rule.dart';
import 'package:work_time_table_mobile/models/event_setting/month_based_repetition_rule.dart';
import 'package:work_time_table_mobile/stream_helpers/identifiable.dart';
import 'package:work_time_table_mobile/models/event_setting/event_type.dart';

class EventSetting implements Identifiable {
  final int id;
  final EventType eventType;
  final String? title;

  final DateTime startDate;
  final DateTime endDate;

  /// Cuts off the first half of the day.
  final bool startIsHalfDay;

  /// Cuts off the second half of the day.
  final bool endIsHalfDay;

  /// Repetition rules used for daily and weekly repetitions.
  final List<DayBasedRepetitionRule> dayBasedRepetitionRules;

  /// Repetition rules used for monthly and yearly repetitions.
  final List<MonthBasedRepetitionRule> monthBasedRepetitionRules;

  EventSetting({
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

  @override
  get identity => id;
}
