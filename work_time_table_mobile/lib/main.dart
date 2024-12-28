import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/blocs/current_user_cubit.dart';
import 'package:work_time_table_mobile/blocs/error_cubit.dart';
import 'package:work_time_table_mobile/blocs/global_setting_cubit.dart';
import 'package:work_time_table_mobile/constants/app_name.dart';
import 'package:work_time_table_mobile/constants/app_observer.dart';
import 'package:work_time_table_mobile/constants/init_test_data.dart';
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

void displayAppError(AppError error) =>
    MyApp.scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(error.displayText)),
    );

Future<void> main() async {
  await initPrismaClient();

  Bloc.observer = const AppObserver();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (details.exception is AppError) {
      displayAppError(details.exception as AppError);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (error is AppError) {
      displayAppError(error);
    }
    return false;
  };

  if (appFlavor == 'docs') {
    print('===== RUNNING DOCS APP =====');
    await initTestData();
  }

  runApp(MultiRepositoryProvider(
    providers: [
      RepositoryProvider(
        lazy: false,
        create: (_) => const UserDao(),
      ),
      RepositoryProvider(
        lazy: false,
        create: (_) => const CurrentUserDao(),
      ),
      RepositoryProvider(
        lazy: false,
        create: (_) => const GlobalSettingDao(),
      ),
      RepositoryProvider(
        lazy: false,
        create: (_) => const WeekSettingDao(),
      ),
      RepositoryProvider(
        lazy: false,
        create: (_) => const EventSettingDao(),
      ),
      RepositoryProvider(
        lazy: false,
        create: (_) => const DayValueDao(),
      ),
      RepositoryProvider(
        lazy: false,
        create: (_) => const WeekValueDao(),
      ),
    ],
    child: const MyApp(),
  ));
}

final router = GoRouter(routes: $appRoutes);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ErrorCubit(),
            lazy: false,
          ),
          BlocProvider(
            create: (_) => CurrentUserCubit(UserService(
              context.read<UserDao>(),
              context.read<CurrentUserDao>(),
            )),
            lazy: false,
          ),
          BlocProvider(
            create: (_) => GlobalSettingCubit(GlobalSettingService(
              UserService(
                context.read<UserDao>(),
                context.read<CurrentUserDao>(),
              ),
              context.read<GlobalSettingDao>(),
            )),
            lazy: false,
          ),
        ],
        child: MaterialApp.router(
          title: appName,
          theme: ThemeData(
            colorScheme: colorScheme,
            useMaterial3: true,
            buttonTheme: buttonTheme,
            cardTheme: cardTheme,
          ),
          routerConfig: router,
          scaffoldMessengerKey: scaffoldMessengerKey,
        ),
      );
}
