import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:work_time_table_mobile/screens/setting/event_setting/edit_event_setting_screen.dart';
import 'package:work_time_table_mobile/screens/setting/event_setting/event_setting_screen.dart';
import 'package:work_time_table_mobile/screens/setting/week_setting/week_setting_screen.dart';
import 'package:work_time_table_mobile/screens/settings_screen.dart';
import 'package:work_time_table_mobile/screens/time_input/time_input_screen.dart';
import 'package:work_time_table_mobile/screens/user/user_screen.dart';

part 'routes.g.dart';

@TypedGoRoute<TimeInputScreenRoute>(path: '/', routes: [
  TypedGoRoute<UserScreenRoute>(path: 'user'),
  TypedGoRoute<SettingsScreenRoute>(path: 'settings'),
  TypedGoRoute<WeekSettingScreenRoute>(path: 'weekSetting'),
  TypedGoRoute<EventSettingScreenRoute>(path: 'eventSetting'),
  TypedGoRoute<EditEventSettingScreenRoute>(path: 'eventSettingEdit'),
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
    return const UserScreen();
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
class EditEventSettingScreenRoute extends GoRouteData {
  final int? eventId;

  const EditEventSettingScreenRoute({
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return EditEventSettingScreen(eventId: eventId);
  }
}
