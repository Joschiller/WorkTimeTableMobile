import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/blocs/event_setting_cubit.dart';
import 'package:work_time_table_mobile/components/confirmable_alert_dialog.dart';
import 'package:work_time_table_mobile/components/editable_list.dart';
import 'package:work_time_table_mobile/components/event_setting/event_calendar.dart';
import 'package:work_time_table_mobile/components/event_setting/event_display.dart';
import 'package:work_time_table_mobile/constants/routes.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/models/event_setting/evaluated_event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/event_type.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/utils.dart';

class EventSettingScreen extends StatelessWidget {
  const EventSettingScreen({super.key});

  Future<void> _showDeletionConfirmation(
    BuildContext context,
    Future<void> Function() doDelete,
  ) async =>
      await showDialog(
        context: context,
        builder: (context) => ConfirmableAlertDialog(
          title: 'Delete Events',
          content: const Text(
              'Do you really want to delete the selected events permanently?'),
          actionText: 'Delete',
          isActionNegative: true,
          onCancel: Navigator.of(context).pop,
          onConfirm: () async {
            await doDelete();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
      );

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => EventSettingCubit(EventSettingService(
          UserService(
            context.read<UserDao>(),
            context.read<CurrentUserDao>(),
          ),
          context.read<EventSettingDao>(),
        )),
        child: BlocSelector<
            EventSettingCubit,
            ContextDependentValue<List<EventSetting>>,
            ContextDependentValue<List<EvaluatedEventSetting>>>(
          selector: (state) => switch (state) {
            NoContextValue<List<EventSetting>>() =>
              NoContextValue<List<EvaluatedEventSetting>>(),
            ContextValue<List<EventSetting>>(value: var value) =>
              ContextValue(value
                  .map(
                    (e) => EvaluatedEventSetting(
                      eventSetting: e,
                      firstHalf: true,
                      secondHalf: true,
                    ),
                  )
                  .toList()
                ..sort((a, b) {
                  final startCompare = a.eventSetting.startDate
                      .compareTo(b.eventSetting.startDate);
                  if (startCompare != 0) return startCompare;

                  final typeCompare = a.eventSetting.eventType.priority -
                      b.eventSetting.eventType.priority;
                  if (typeCompare != 0) return typeCompare;

                  final endCompare =
                      a.eventSetting.endDate.compareTo(b.eventSetting.endDate);
                  if (endCompare != 0) return endCompare;

                  return (a.eventSetting.title ?? '')
                      .compareTo(b.eventSetting.title ?? '');
                })),
          },
          builder: (context, state) => switch (state) {
            NoContextValue<List<EvaluatedEventSetting>>() => const Center(
                child: Text('No user selected'),
              ),
            ContextValue<List<EvaluatedEventSetting>>(value: var value) =>
              EditableList<EvaluatedEventSetting>(
                title: 'Event Settings',
                items: value,
                // TODO: always show the nearest next instance of that event -> should be realized whilst creating the time input logic
                templateItem: EvaluatedEventSetting(
                  eventSetting: EventSetting(
                    id: -1,
                    eventType: EventType.dayOff,
                    title: 'Evemt',
                    startDate: DateTime.now().toDay(),
                    endDate: DateTime.now().toDay(),
                    startIsHalfDay: false,
                    endIsHalfDay: false,
                    dayBasedRepetitionRules: [],
                    monthBasedRepetitionRules: [],
                  ),
                  firstHalf: true,
                  secondHalf: true,
                ),
                buildItem: (item, selected) => EventDisplay(
                  event: item,
                  selected: selected,
                ),
                onAdd: () => const AddEventSettingScreenRoute().push(context),
                onTapItem: (index) => EditEventSettingScreenRoute(
                        eventId: value[index].eventSetting.id)
                    .push(context),
                onRemove: (items) => _showDeletionConfirmation(
                  context,
                  () => context.read<EventSettingCubit>().deleteEvents(
                        items.map((event) => event.eventSetting.id).toList(),
                        true,
                      ),
                ),
                detailInformation: EventCalendar(
                  events: value.map((e) => e.eventSetting).toList(),
                ),
              ),
          },
        ),
      );
}
