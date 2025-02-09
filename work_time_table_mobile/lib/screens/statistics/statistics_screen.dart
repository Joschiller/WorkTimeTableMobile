import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/blocs/statistics_cubit.dart';
import 'package:work_time_table_mobile/components/no_user_page.dart';
import 'package:work_time_table_mobile/components/page_template.dart';
import 'package:work_time_table_mobile/components/statistics/not_enough_data_page.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/day_value_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/daos/week_value_dao.dart';
import 'package:work_time_table_mobile/models/statistics/statistics_state.dart';
import 'package:work_time_table_mobile/services/statistics_service.dart';
import 'package:work_time_table_mobile/services/user_service.dart';

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
          child: BlocBuilder<StatisticsCubit, StatisticsState>(
            builder: (context, state) => switch (state) {
              StatisticsStateNoUser() => const NoUserPage(
                  title: 'Statistics',
                ),
              StatisticsStateNotEnoughData() => const NotEnoughDataPage(
                  title: 'Statistics',
                ),
              StatisticsStateResult() => const PageTemplate(
                  title: 'Statistics',
                  content: Placeholder(),
                ),
            },
          ),
        ),
      );
}
