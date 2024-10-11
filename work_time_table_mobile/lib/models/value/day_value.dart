import 'package:work_time_table_mobile/streamed_dao_helpers/identifiable.dart';
import 'package:work_time_table_mobile/models/value/day_mode.dart';

class DayValue implements Identifiable {
  final DateTime date;

  final DayMode mode;
  final int workTimeStart;
  final int workTimeEnd;
  final int breakDuration;

  DayValue({
    required this.date,
    required this.mode,
    required this.workTimeStart,
    required this.workTimeEnd,
    required this.breakDuration,
  });

  @override
  get identity => date;
}
