import 'package:work_time_table_mobile/daos/day_value_dao.dart';
import 'package:work_time_table_mobile/daos/week_value_dao.dart';
import 'package:work_time_table_mobile/models/statistics/statistics_state.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/streamable_service.dart';

class StatisticsService extends StreamableService {
  StatisticsService(
    this._userService,
    this._dayValueDao,
    this._weekValueDao,
  ) {
    registerSubscription(_userService.currentUserStream.stream
        .listen((selectedUser) => runContextDependentAction(
              selectedUser,
              () => loadData(null),
              (user) => loadData(user.id),
            )));
    prepareComplexListen(
      [_dayValueDao.stream, _weekValueDao.stream],
      () => _calculateState(
        _dayValueDao.stream.state,
        _weekValueDao.stream.state,
      ),
      statisticsStream,
    );
    runContextDependentAction(
      _userService.currentUserStream.state,
      () => loadData(null),
      (user) => loadData(user.id),
    );
  }

  final UserService _userService;
  final DayValueDao _dayValueDao;
  final WeekValueDao _weekValueDao;

  final statisticsStream = ContextDependentStream<StatisticsState>();

  ContextDependentValue<StatisticsState> _calculateState(
    ContextDependentValue<List<DayValue>> contextDays,
    ContextDependentValue<List<WeekValue>> contextWeeks,
  ) =>
      runContextDependentAction(
        contextDays,
        () => NoContextValue(),
        (days) => runContextDependentAction(
          contextWeeks,
          () => NoContextValue(),
          (weeks) {
            // TODO: fill with data
            return ContextValue(
              StatisticsState(
                notEnoughDataWarning: weeks.length <= 25,
              ),
            );
          },
        ),
      );

  Future<void> loadData(int? userId) async {
    await _dayValueDao.loadUserValues(userId);
    await _weekValueDao.loadUserValues(userId);
  }

  @override
  void close() {
    super.close();
    _userService.close();
  }
}
