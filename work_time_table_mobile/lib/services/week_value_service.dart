import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/services/day_value_service.dart';
import 'package:work_time_table_mobile/stream_helpers/identifiable.dart';

class WeekInformation implements Identifiable {
  final DateTime weekStartDate;
  final int resultOfPredecessorWeek;
  final Map<DayOfWeek, DayValue> days;
  final int weekResult;
  final bool weekClosed;

  WeekInformation({
    required this.weekStartDate,
    required this.resultOfPredecessorWeek,
    required this.days,
    required this.weekResult,
    required this.weekClosed,
  });

  @override
  get identity => weekStartDate;
}

typedef MergedDaoValues = ({
  WeekSetting weekSetting,
  List<EventSetting> eventSettings,
  List<DayValue> dayValues,
  List<WeekValue> weekValues,
});

class WeekValueService {
  const WeekValueService(this._dayValueService);

  final DayValueService _dayValueService;

  WeekInformation getValuesForWeek(
    DateTime weekStartDate,
    MergedDaoValues values,
  ) {
    // week value
    final week = values.weekValues
        .where((week) => week.weekStartDate == weekStartDate)
        .firstOrNull;

    // day values
    final days = <DayOfWeek, DayValue>{};
    for (final dayOfWeek in DayOfWeek.values) {
      final dateOfDay = weekStartDate.add(Duration(days: dayOfWeek.index));
      days[dayOfWeek] =
          // stored value
          (values.dayValues
                  .where((day) => day.date == dateOfDay)
                  .firstOrNull) ??
              // or initial value
              _dayValueService.getInitialValueForDay(
                dateOfDay,
                values.weekSetting,
                values.eventSettings,
              );
    }

    // resultOfPredecessorWeek
    final firstClosedWeek = values.weekValues.firstOrNull?.weekStartDate;
    final predecessorDays = values.dayValues.where((day) =>
        day.date.isBefore(weekStartDate) &&
        // ignore days that are before the first closed week and therefore will never be closed
        (firstClosedWeek == null || !day.date.isBefore(firstClosedWeek)));
    final resultOfPredecessorWeek = predecessorDays.isEmpty
        ? 0
        // TODO: theoretically needs to also sum up all default values for the unsaved days sbefore the current week, but this may be a theoretical scenario
        : predecessorDays
                .map((day) =>
                    day.workTimeEnd - day.workTimeStart - day.breakDuration)
                .reduce((a, b) => a + b) -
            (values.weekValues.isEmpty
                ? 0
                : values.weekValues
                    .where((week) => week.weekStartDate.isBefore(weekStartDate))
                    .map((week) => week.targetTime)
                    .reduce((a, b) => a + b));
    // TODO: theoretically needs to also substract all target values for the unsaved weeks sbefore the current week, but this may be a theoretical scenario

    return WeekInformation(
      weekStartDate: weekStartDate,
      resultOfPredecessorWeek: resultOfPredecessorWeek,
      days: days,
      weekResult: resultOfPredecessorWeek +
          (days.values.isEmpty
              ? 0
              : days.values
                  .map((day) =>
                      day.workTimeEnd - day.workTimeStart - day.breakDuration)
                  .reduce((a, b) => a + b)) -
          (week?.targetTime ?? values.weekSetting.targetWorkTimePerWeek),
      weekClosed: week != null ||
          values.weekValues
              .any((week) => week.weekStartDate.isBefore(weekStartDate)),
    );
  }
}
