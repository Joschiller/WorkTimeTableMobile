import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/models/statistics/statistics_state.dart';
import 'package:work_time_table_mobile/services/statistics_service.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
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
