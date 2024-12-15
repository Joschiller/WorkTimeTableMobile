import 'package:flutter/material.dart';

extension IsBlank on String {
  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => trim().isNotEmpty;
}

extension DateTimeToDay on DateTime {
  DateTime toDay() => DateTime.utc(year, month, day);
}

extension IntToTimeOfDay on int {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: this ~/ 60, minute: this % 60);
}

extension TimeOfDayToInt on TimeOfDay {
  int toInt() => 60 * hour + minute;
}

extension StringToCapitalized on String {
  String get capitalized =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}

extension DateTimeCounter on DateTime {
  int get countOfDayInMonth => DateTimeRange(
        start: DateTime.utc(year, month),
        end: DateTime.utc(year, month + 1),
      ).duration.inDays;
}
