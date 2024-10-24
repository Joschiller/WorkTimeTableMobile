import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/models/event_setting/day_based_repetition_rule.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/month_based_repetition_rule.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';

typedef EventRangeCheckResult = ({bool firstHalf, bool secondHalf});

extension EventRangeCheckResultOr on EventRangeCheckResult {
  EventRangeCheckResult operator |(EventRangeCheckResult other) => (
        firstHalf: this.firstHalf || other.firstHalf,
        secondHalf: this.secondHalf || other.secondHalf,
      );
}

class EventService {
  const EventService();

  EventRangeCheckResult doesEventAffectDate(
    DateTime targetDate,
    EventSetting event,
  ) {
    EventRangeCheckResult result = (firstHalf: false, secondHalf: false);
    // check event base values

    result = result |
        _isDateInRange(targetDate, (
          start: event.startDate,
          end: event.endDate,
          startIsHalfDay: event.startIsHalfDay,
          endIsHalfDay: event.endIsHalfDay,
        ));

    final eventDuration = DateTimeRange(
      start: event.startDate,
      end: event.endDate,
    ).duration;

    // check repetitions
    for (final daybasedRepetition in event.dayBasedRepetitionRules) {
      var currentStartDate = _getNextOccurenceOfDayBasedRepetition(
        event.startDate,
        daybasedRepetition,
      );
      while (!targetDate.isBefore(currentStartDate)) {
        // check range
        result = result |
            _isDateInRange(targetDate, (
              start: currentStartDate,
              end: currentStartDate.add(eventDuration),
              startIsHalfDay: event.startIsHalfDay,
              endIsHalfDay: event.endIsHalfDay,
            ));

        currentStartDate = _getNextOccurenceOfDayBasedRepetition(
          currentStartDate,
          daybasedRepetition,
        );
      }
    }
    for (final monthBasedRepetitions in event.monthBasedRepetitionRules) {
      var currentStartDate = _getNextOccurenceOfMonthBasedRepetition(
        event.startDate,
        monthBasedRepetitions,
      );
      while (!targetDate.isBefore(currentStartDate)) {
        // check range
        result = result |
            _isDateInRange(targetDate, (
              start: currentStartDate,
              end: currentStartDate.add(eventDuration),
              startIsHalfDay: event.startIsHalfDay,
              endIsHalfDay: event.endIsHalfDay,
            ));

        currentStartDate = _getNextOccurenceOfMonthBasedRepetition(
          currentStartDate,
          monthBasedRepetitions,
        );
      }
    }

    return result;
  }

  DateTime _getNextOccurenceOfDayBasedRepetition(
    DateTime currentDate,
    DayBasedRepetitionRule repetition,
  ) =>
      currentDate.add(Duration(
        days: repetition.repeatAfterDays,
      ));

  DateTime _getNextOccurenceOfMonthBasedRepetition(
    DateTime currentDate,
    MonthBasedRepetitionRule repetition,
  ) {
    final targetMonth = DateTime(
      currentDate.year,
      currentDate.month + repetition.repeatAfterMonths,
    );
    final countOfDaysInMonth = DateTimeRange(
      start: targetMonth,
      end: DateTime(targetMonth.year, targetMonth.month + 1),
    ).duration.inDays;

    final weekIndex = repetition.weekIndex;

    if (weekIndex == null) {
      return DateTime(
        targetMonth.year,
        targetMonth.month,
        repetition.countFromEnd
            ? countOfDaysInMonth - repetition.dayIndex
            : repetition.dayIndex + 1,
      );
    } else {
      final instancesOfDayOfWeek = <DateTime>[];
      for (var i = 0; i < countOfDaysInMonth; i++) {
        final dayToTest = targetMonth.add(Duration(days: i));
        if (DayOfWeek.fromDateTime(dayToTest) ==
                DayOfWeek.values[repetition.dayIndex]
            // check hours for some special cases (e.g. searching for sundays in 10/2024)
            &&
            dayToTest.hour == 0) {
          instancesOfDayOfWeek.add(dayToTest);
        }
      }
      return instancesOfDayOfWeek[repetition.countFromEnd
          ? instancesOfDayOfWeek.length - weekIndex - 1
          : weekIndex];
    }
  }

  EventRangeCheckResult _isDateInRange(
    DateTime targetDate,
    ({
      DateTime start,
      DateTime end,
      bool startIsHalfDay,
      bool endIsHalfDay,
    }) range,
  ) =>
      (!targetDate.isBefore(range.start) && !targetDate.isAfter(range.end))
          ? (
              firstHalf:
                  !range.startIsHalfDay || range.start.isBefore(targetDate),
              secondHalf: !range.endIsHalfDay || range.end.isAfter(targetDate),
            )
          : (firstHalf: false, secondHalf: false);
}
