import 'package:scidart/numdart.dart';
import 'package:work_time_table_mobile/models/statistics/statistics_mode.dart';

double? analyzeList<T>(
  Iterable<T>? list,
  double Function(T item) extractData,
  StatisticsMode statisticsMode,
) {
  if (list == null || list.isEmpty) {
    return null;
  }

  final mappedList = list.map(extractData).toList();

  return switch (statisticsMode) {
    StatisticsMode.average => mean(Array(mappedList)),
    StatisticsMode.median => median(Array(mappedList)),
    StatisticsMode.mode => mode(Array(mappedList)),
  };
}
