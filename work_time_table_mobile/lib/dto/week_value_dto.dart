import 'package:work_time_table_mobile/utils.dart';

class WeekValueDto {
  final DateTime weekStartDate;
  final int targetTime;

  WeekValueDto({required this.weekStartDate, required this.targetTime});

  factory WeekValueDto.fromJson(Map<String, dynamic> json) => WeekValueDto(
        weekStartDate: DateTime.parse(json['weekStartDate']),
        targetTime: json['targetTime'],
      );

  Map<String, dynamic> toJson() => {
        'weekStartDate': technicalDateFormat.format(weekStartDate),
        'targetTime': targetTime,
      };
}
