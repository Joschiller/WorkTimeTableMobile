import 'package:work_time_table_mobile/stream_helpers/identifiable.dart';

class WeekValue implements Identifiable {
  final DateTime weekStartDate;

  final int targetTime;

  WeekValue({required this.weekStartDate, required this.targetTime});

  @override
  get identity => weekStartDate;
}
