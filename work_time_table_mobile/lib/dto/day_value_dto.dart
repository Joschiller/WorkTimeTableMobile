import 'package:work_time_table_mobile/models/value/day_mode.dart';
import 'package:work_time_table_mobile/utils.dart';

class DayValueDto {
  final DateTime date;

  final DayMode firstHalfMode;
  final DayMode secondHalfMode;
  final int workTimeStart;
  final int workTimeEnd;
  final int breakDuration;

  DayValueDto({
    required this.date,
    required this.firstHalfMode,
    required this.secondHalfMode,
    required this.workTimeStart,
    required this.workTimeEnd,
    required this.breakDuration,
  });

  factory DayValueDto.fromJson(Map<String, dynamic> json) => DayValueDto(
        date: DateTime.parse(json['date']),
        firstHalfMode: json['firstHalfMode'],
        secondHalfMode: json['secondHalfMode'],
        workTimeStart: json['workTimeStart'],
        workTimeEnd: json['workTimeEnd'],
        breakDuration: json['breakDuration'],
      );

  Map<String, dynamic> toJson() => {
        'date': technicalDateFormat.format(date),
        'firstHalfMode': firstHalfMode,
        'secondHalfMode': secondHalfMode,
        'workTimeStart': workTimeStart,
        'workTimeEnd': workTimeEnd,
        'breakDuration': breakDuration,
      };
}
