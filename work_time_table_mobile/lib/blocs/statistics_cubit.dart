import 'dart:async';

import 'package:work_time_table_mobile/models/statistics/statistics_state.dart';
import 'package:work_time_table_mobile/services/statistics_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_cubit.dart';

class StatisticsCubit extends ContextDependentCubit<StatisticsState> {
  late StreamSubscription _subscription;

  StatisticsCubit(this._statisticsService)
      : super(_statisticsService.statisticsStream.state) {
    _subscription = _statisticsService.statisticsStream.stream.listen(emit);
  }

  final StatisticsService _statisticsService;

  @override
  Future<void> close() {
    _subscription.cancel();
    _statisticsService.close();
    return super.close();
  }
}
