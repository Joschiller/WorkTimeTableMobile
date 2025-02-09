import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:work_time_table_mobile/screens/setting/event_setting/edit_event_setting_screen.dart';
import 'package:work_time_table_mobile/screens/setting/event_setting/event_setting_screen.dart';
import 'package:work_time_table_mobile/screens/setting/global_setting/global_setting_screen.dart';
import 'package:work_time_table_mobile/screens/setting/week_setting/week_setting_screen.dart';
import 'package:work_time_table_mobile/screens/setting/settings_screen.dart';
import 'package:work_time_table_mobile/screens/statistics/statistics_screen.dart';
import 'package:work_time_table_mobile/screens/time_input/time_input_screen.dart';
import 'package:work_time_table_mobile/screens/user/user_screen.dart';

part 'routes.g.dart';

// generate with: flutter pub run build_runner build

@TypedGoRoute<TimeInputScreenRoute>(path: '/', routes: [
  TypedGoRoute<UserScreenRoute>(path: 'settings/user'),
  TypedGoRoute<UserScreenForCreationRoute>(path: 'settings/user/create'),
  TypedGoRoute<SettingsScreenRoute>(path: 'settings'),
  TypedGoRoute<WeekSettingScreenRoute>(path: 'settings/week'),
  TypedGoRoute<EventSettingScreenRoute>(path: 'settings/event'),
  TypedGoRoute<AddEventSettingScreenRoute>(path: 'settings/event/edit'),
  TypedGoRoute<EditEventSettingScreenRoute>(
      path: 'settings/event/edit/:eventId'),
  TypedGoRoute<GlobalSettingScreenRoute>(path: 'settings/global'),
  TypedGoRoute<StatisticsScreenRoute>(path: 'statistics'),
])
@immutable
class TimeInputScreenRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TimeInputScreen();
  }
}

@immutable
class UserScreenRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const UserScreen(
      immediatelyShowAddDialog: false,
    );
  }
}

@immutable
class UserScreenForCreationRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const UserScreen(
      immediatelyShowAddDialog: true,
    );
  }
}

@immutable
class SettingsScreenRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}

@immutable
class WeekSettingScreenRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WeekSettingScreen();
  }
}

@immutable
class EventSettingScreenRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const EventSettingScreen();
  }
}

@immutable
class AddEventSettingScreenRoute extends GoRouteData {
  const AddEventSettingScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const EditEventSettingScreen(eventId: null);
  }
}

@immutable
class EditEventSettingScreenRoute extends GoRouteData {
  final int eventId;

  const EditEventSettingScreenRoute({
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return EditEventSettingScreen(eventId: eventId);
  }
}

@immutable
class GlobalSettingScreenRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const GlobalSettingScreen();
  }
}

@immutable
class StatisticsScreenRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const StatisticsScreen();
  }
}
