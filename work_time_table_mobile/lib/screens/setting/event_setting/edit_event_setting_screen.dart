import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:work_time_table_mobile/blocs/event_setting_cubit.dart';
import 'package:work_time_table_mobile/components/settings/event_setting/event_setting_editor.dart';
import 'package:work_time_table_mobile/components/page_template.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/services/event_service.dart';
import 'package:work_time_table_mobile/services/event_setting_service.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

class EditEventSettingScreen extends StatelessWidget {
  const EditEventSettingScreen({super.key, this.eventId});

  final int? eventId;

  @override
  Widget build(BuildContext context) => PageTemplate(
        title: 'Event Setting',
        content: BlocProvider(
          create: (context) => EventSettingCubit(EventSettingService(
            UserService(
              context.read<UserDao>(),
              context.read<CurrentUserDao>(),
            ),
            context.read<EventSettingDao>(),
            const EventService(),
          )),
          child: BlocBuilder<EventSettingCubit,
              ContextDependentValue<List<EventSetting>>>(
            builder: (context, state) => switch (state) {
              NoContextValue<List<EventSetting>>() => const Center(
                  child: Text('No user selected'),
                ),
              ContextValue<List<EventSetting>>(value: var value) =>
                EventSettingEditor(
                  initialValue: value
                      .where((element) => element.id == eventId)
                      .firstOrNull,
                  onCancel: context.pop,
                  onSubmit: (value) async {
                    if (eventId == null) {
                      await context.read<EventSettingCubit>().addEvent(value);
                    } else {
                      await context
                          .read<EventSettingCubit>()
                          .updateEvent(value);
                    }
                    if (!context.mounted) return;
                    context.pop();
                  },
                ),
            },
          ),
        ),
      );
}
