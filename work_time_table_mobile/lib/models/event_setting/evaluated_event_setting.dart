import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/stream_helpers/identifiable.dart';

class EvaluatedEventSetting implements Identifiable {
  final EventSetting eventSetting;
  final bool firstHalf;
  final bool secondHalf;

  EvaluatedEventSetting({
    required this.eventSetting,
    required this.firstHalf,
    required this.secondHalf,
  });

  @override
  get identity => eventSetting.identity;
}
