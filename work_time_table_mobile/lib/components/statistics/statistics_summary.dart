import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/statistics/statistics_mode_selector.dart';
import 'package:work_time_table_mobile/models/statistics/statistics_mode.dart';
import 'package:work_time_table_mobile/models/statistics/statistics_state.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/services/analyze_list.dart';

class StatisticsSummary extends StatefulWidget {
  const StatisticsSummary({super.key, required this.statistics});

  final StatisticsState statistics;

  @override
  State<StatisticsSummary> createState() => _StatisticsSummaryState();
}

class _StatisticsSummaryState extends State<StatisticsSummary> {
  var _statisticsMode = StatisticsMode.average;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatisticsModeSelector(
            statisticsMode: _statisticsMode,
            onChange: (statisticsMode) => setState(
              () {
                _statisticsMode = statisticsMode;
              },
            ),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Work Days Per Week:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: Text(
                  analyzeList(
                    widget.statistics.workDaysInWeek,
                    (item) => item,
                    _statisticsMode,
                  ).toString(),
                ),
              ),
            ],
          ),
          for (final day in DayOfWeek.values)
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${day.name}:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: !widget.statistics.dayValuesPerDayOfWeek.values
                          .any((v) => v.isNotEmpty)
                      ? const Text('No Data')
                      : Row(
                          children: [
                            const Text('Work Period: '),
                            Text(
                              _durationToString(Duration(
                                minutes: analyzeList<DayValue>(
                                      widget.statistics
                                          .dayValuesPerDayOfWeek[day],
                                      (item) => item.workTimeStart.toDouble(),
                                      _statisticsMode,
                                    )?.toInt() ??
                                    0,
                              )),
                            ),
                            const Text(' - '),
                            Text(
                              _durationToString(Duration(
                                minutes: analyzeList<DayValue>(
                                      widget.statistics
                                          .dayValuesPerDayOfWeek[day],
                                      (item) => item.workTimeEnd.toDouble(),
                                      _statisticsMode,
                                    )?.toInt() ??
                                    0,
                              )),
                            ),
                            const SizedBox(width: 16),
                            const Text('Break Duration: '),
                            Text(
                              _durationToString(Duration(
                                minutes: analyzeList<DayValue>(
                                      widget.statistics
                                          .dayValuesPerDayOfWeek[day],
                                      (item) => item.breakDuration.toDouble(),
                                      _statisticsMode,
                                    )?.toInt() ??
                                    0,
                              )),
                            ),
                          ],
                        ),
                ),
              ],
            ),
        ],
      );
}

String _durationToString(Duration duration) =>
    '${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')} h';
