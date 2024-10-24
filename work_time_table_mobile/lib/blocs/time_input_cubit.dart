import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/services/time_input_service.dart';
import 'package:work_time_table_mobile/services/week_value_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_cubit.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/multi_stream_listener.dart';

class TimeInputCubit extends ContextDependentCubit<WeekInformation> {
  TimeInputCubit(this.timeInputService) : super() {
    listenForStreams(
      [
        timeInputService.weekSettingStream.stream,
        timeInputService.eventSettingStream.stream,
        timeInputService.dayValueStream.stream,
        timeInputService.weekValueStream.stream,
      ],
      () => _loadValueForWeek(0),
    );
    // TODO: logic for loading the initial values once a user is loaded => should load current week
  }

  TimeInputService timeInputService;

  static bool isWeekClosed(
    List<WeekValue> weekValues,
    DateTime weekStartDate,
  ) =>
      TimeInputService.isWeekClosed(weekValues, weekStartDate);

  Future<void> updateDaysOfWeek(List<DayValue> values) =>
      timeInputService.updateDaysOfWeek(values);

  Future<void> resetDaysOfWeek(DateTime weekStartDate, bool isConfirmed) =>
      timeInputService.resetDaysOfWeek(weekStartDate, isConfirmed);

  Future<void> closeWeek(
    WeekValue value,
    List<DayValue> dayValues,
    bool isConfirmed,
  ) =>
      timeInputService.closeWeek(value, dayValues, isConfirmed);

  void _loadValueForWeek(int relativeWeeks) => emit(switch (state) {
        NoContextValue() => NoContextValue(),
        ContextValue(value: var weekInformation) =>
          timeInputService.getValuesForWeek(
            weekInformation.weekStartDate
                .add(Duration(days: 7 * relativeWeeks)),
          ),
      });

  void weekForwards() => _loadValueForWeek(1);

  void weekBackwards() => _loadValueForWeek(-1);
}
