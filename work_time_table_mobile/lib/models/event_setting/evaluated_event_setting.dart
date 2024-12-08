import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';

class EvaluatedEventSetting {
  final EventSetting eventSetting;
  final bool firstHalf;
  final bool secondHalf;

  EvaluatedEventSetting({
    required this.eventSetting,
    required this.firstHalf,
    required this.secondHalf,
  });
}
