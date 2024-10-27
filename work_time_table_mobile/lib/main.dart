import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:work_time_table_mobile/blocs/current_user_cubit.dart';
import 'package:work_time_table_mobile/blocs/error_cubit.dart';
import 'package:work_time_table_mobile/blocs/global_setting_cubit.dart';
import 'package:work_time_table_mobile/constants/app_name.dart';
import 'package:work_time_table_mobile/constants/app_observer.dart';
import 'package:work_time_table_mobile/constants/routes.dart';
import 'package:work_time_table_mobile/constants/theme.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/day_value_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/daos/global_setting_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/daos/week_value_dao.dart';
import 'package:work_time_table_mobile/prisma.dart';
import 'package:work_time_table_mobile/services/global_setting_service.dart';
import 'package:work_time_table_mobile/services/user_service.dart';

Future<void> main() async {
  await initPrismaClient();

  Bloc.observer = const AppObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (_) => const UserDao()),
          RepositoryProvider(create: (_) => const CurrentUserDao()),
          RepositoryProvider(create: (_) => const GlobalSettingDao()),
          RepositoryProvider(create: (_) => const WeekSettingDao()),
          RepositoryProvider(create: (_) => const EventSettingDao()),
          RepositoryProvider(create: (_) => const DayValueDao()),
          RepositoryProvider(create: (_) => const WeekValueDao()),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ErrorCubit()),
            BlocProvider(
                create: (_) => CurrentUserCubit(UserService(
                      context.read<UserDao>(),
                      context.read<CurrentUserDao>(),
                    ))),
            BlocProvider(
                create: (_) => GlobalSettingCubit(GlobalSettingService(
                      UserService(
                        context.read<UserDao>(),
                        context.read<CurrentUserDao>(),
                      ),
                      context.read<GlobalSettingDao>(),
                    ))),
          ],
          child: MaterialApp.router(
            title: appName,
            theme: ThemeData(
              colorScheme: colorScheme,
              useMaterial3: true,
              buttonTheme: buttonTheme,
              cardTheme: cardTheme,
            ),
            routerConfig: GoRouter(routes: $appRoutes),
          ),
        ),
      );
}
