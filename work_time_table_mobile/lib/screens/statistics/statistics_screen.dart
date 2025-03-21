import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/blocs/statistics_cubit.dart';
import 'package:work_time_table_mobile/components/no_user_page.dart';
import 'package:work_time_table_mobile/components/page_template.dart';
import 'package:work_time_table_mobile/components/statistics/not_enough_data_warning.dart';
import 'package:work_time_table_mobile/components/statistics/statistics_summary.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/day_value_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/daos/week_value_dao.dart';
import 'package:work_time_table_mobile/models/statistics/statistics_state.dart';
import 'package:work_time_table_mobile/services/statistics_service.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => UserService(
              context.read<UserDao>(),
              context.read<CurrentUserDao>(),
            ),
          ),
          RepositoryProvider(
            create: (context) => StatisticsService(
              context.read<UserService>(),
              context.read<DayValueDao>(),
              context.read<WeekValueDao>(),
            ),
          ),
        ],
        child: BlocProvider(
          create: (context) => StatisticsCubit(
            context.read<StatisticsService>(),
          ),
          child: BlocBuilder<StatisticsCubit,
              ContextDependentValue<StatisticsState>>(
            builder: (context, state) => switch (state) {
              NoContextValue() => const NoUserPage(
                  title: 'Statistics',
                ),
              ContextValue(value: final statistics) => PageTemplate(
                  title: 'Statistics',
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (statistics.notEnoughDataWarning)
                          const NotEnoughDataWarning(),
                        const Divider(
                          height: 24,
                          thickness: 1,
                        ),
                        StatisticsSummary(statistics: statistics),
                        const Divider(
                          height: 24,
                          thickness: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            },
          ),
        ),
      );
}
