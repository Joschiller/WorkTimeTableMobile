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
    final eventDuration = DateTimeRange(
      start: event.startDate,
      end: event.endDate,
    ).duration;

    var result = _isDateInRange(
      // check event base values
      targetDate,
      (
        start: event.startDate,
        end: event.endDate,
        startIsHalfDay: event.startIsHalfDay,
        endIsHalfDay: event.endIsHalfDay,
      ),
    );
    if (result.firstHalf && result.secondHalf) {
      return result;
    }

    // check repetitions
    result = result |
        _checkRepetitions(
          targetDate,
          (
            startDate: event.startDate,
            duration: eventDuration,
            startIsHalfDay: event.startIsHalfDay,
            endIsHalfDay: event.endIsHalfDay,
            repetitions: event.dayBasedRepetitionRules,
          ),
          _getNextOccurenceOfDayBasedRepetition,
        );
    if (result.firstHalf && result.secondHalf) {
      return result;
    }

    result = result |
        _checkRepetitions(
          targetDate,
          (
            startDate: event.startDate,
            duration: eventDuration,
            startIsHalfDay: event.startIsHalfDay,
            endIsHalfDay: event.endIsHalfDay,
            repetitions: event.monthBasedRepetitionRules,
          ),
          _getNextOccurenceOfMonthBasedRepetition,
        );
    return result;
  }

  EventRangeCheckResult _checkRepetitions<T>(
    DateTime targetDate,
    ({
      DateTime startDate,
      Duration duration,
      bool startIsHalfDay,
      bool endIsHalfDay,
      List<T> repetitions,
    }) eventInfo,
    DateTime Function(DateTime currentStartDate, T repetition)
        getNextRepetition,
  ) {
    EventRangeCheckResult result = (firstHalf: false, secondHalf: false);

    for (final repetition in eventInfo.repetitions) {
      var currentStartDate = getNextRepetition(
        eventInfo.startDate,
        repetition,
      );
      while (!targetDate.isBefore(currentStartDate)) {
        // check range
        result = result |
            _isDateInRange(targetDate, (
              start: currentStartDate,
              end: currentStartDate.add(eventInfo.duration),
              startIsHalfDay: eventInfo.startIsHalfDay,
              endIsHalfDay: eventInfo.endIsHalfDay,
            ));

        if (result.firstHalf && result.secondHalf) {
          return result;
        }

        currentStartDate = getNextRepetition(
          currentStartDate,
          repetition,
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

    final weekIndex = repetition.monthBasedRepetitionRuleBase.weekIndex;

    if (weekIndex == null) {
      return DateTime(
        targetMonth.year,
        targetMonth.month,
        repetition.monthBasedRepetitionRuleBase.countFromEnd
            ? countOfDaysInMonth -
                repetition.monthBasedRepetitionRuleBase.dayIndex
            : repetition.monthBasedRepetitionRuleBase.dayIndex + 1,
      );
    } else {
      final instancesOfDayOfWeek = <DateTime>[];
      for (var i = 0; i < countOfDaysInMonth; i++) {
        final dayToTest = targetMonth.add(Duration(days: i));
        if (DayOfWeek.fromDateTime(dayToTest) ==
                DayOfWeek
                    .values[repetition.monthBasedRepetitionRuleBase.dayIndex]
            // check hours for some special cases (e.g. searching for sundays in 10/2024)
            &&
            dayToTest.hour == 0) {
          instancesOfDayOfWeek.add(dayToTest);
        }
      }
      return instancesOfDayOfWeek[
          repetition.monthBasedRepetitionRuleBase.countFromEnd
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
