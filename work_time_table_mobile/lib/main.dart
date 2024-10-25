import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:work_time_table_mobile/blocs/current_user_cubit.dart';
import 'package:work_time_table_mobile/blocs/error_cubit.dart';
import 'package:work_time_table_mobile/blocs/event_setting_cubit.dart';
import 'package:work_time_table_mobile/blocs/global_setting_cubit.dart';
import 'package:work_time_table_mobile/blocs/time_input_cubit.dart';
import 'package:work_time_table_mobile/blocs/user_cubit.dart';
import 'package:work_time_table_mobile/blocs/week_setting_cubit.dart';
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
import 'package:work_time_table_mobile/services/day_value_service.dart';
import 'package:work_time_table_mobile/services/event_service.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/services/global_setting_service.dart';
import 'package:work_time_table_mobile/services/time_input_service.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/services/week_setting_service.dart';
import 'package:work_time_table_mobile/services/week_value_service.dart';

void main() {
  Bloc.observer = const AppObserver();

  final userService = UserService(const UserDao(), CurrentUserDao());
  final globalSettingService =
      GlobalSettingService(userService, const GlobalSettingDao());
  final weekSettingService =
      WeekSettingService(userService, const WeekSettingDao());
  final eventSettingService =
      EventSettingService(userService, const EventSettingDao());
  final timeInputService = TimeInputService(
    userService,
    weekSettingService,
    eventSettingService,
    const DayValueDao(),
    const WeekValueDao(),
    const WeekValueService(DayValueService(EventService())),
  );

  runApp(MyApp(
    userService: userService,
    globalSettingService: globalSettingService,
    weekSettingService: weekSettingService,
    eventSettingService: eventSettingService,
    timeInputService: timeInputService,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.userService,
    required this.globalSettingService,
    required this.weekSettingService,
    required this.eventSettingService,
    required this.timeInputService,
  });

  final UserService userService;
  final GlobalSettingService globalSettingService;
  final WeekSettingService weekSettingService;
  final EventSettingService eventSettingService;
  final TimeInputService timeInputService;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ErrorCubit()),
          BlocProvider(create: (_) => UserCubit(userService)),
          BlocProvider(create: (_) => CurrentUserCubit(userService)),
          BlocProvider(create: (_) => GlobalSettingCubit(globalSettingService)),
          BlocProvider(create: (_) => WeekSettingCubit(weekSettingService)),
          BlocProvider(create: (_) => EventSettingCubit(eventSettingService)),
          BlocProvider(
              create: (_) => TimeInputCubit(
                    userService,
                    weekSettingService,
                    eventSettingService,
                    timeInputService,
                  )),
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
      );
}
