import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/client.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/daos/mapper/event_setting_mapper.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/prisma.dart';
import 'package:work_time_table_mobile/stream_helpers/context/list/context_dependent_list_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/dao_deletion_helper.dart';

final _stream = ContextDependentListStream<EventSetting>();

const _include = EventSettingInclude(
  dayBasedRepetitionRule: PrismaUnion.$1(true),
  monthBasedRepetitionRule: PrismaUnion.$1(true),
);

class EventSettingDao {
  const EventSettingDao();

  Future<void> loadUserSettings(int? userId) async {
    if (userId == null) {
      _stream.emitReload(NoContextValue());
      return;
    }
    final settings = await prisma.eventSetting.findMany(
      where: EventSettingWhereInput(userId: PrismaUnion.$2(userId)),
      include: _include,
    );
    _stream
        .emitReload(ContextValue(settings.map((s) => s.toAppModel()).toList()));
  }

  Future<prisma_model.EventSetting> _create(
    PrismaClient client,
    int userId,
    EventSetting event,
  ) async =>
      await client.eventSetting.create(
        data: PrismaUnion.$1(EventSettingCreateInput(
          type: event.eventType.name,
          title: event.title != null
              ? PrismaUnion.$1(event.title!)
              : const PrismaUnion.$2(PrismaNull()),
          startDate: event.startDate,
          endDate: event.endDate,
          startIsHalfDay: event.startIsHalfDay,
          endIsHalfDay: event.endIsHalfDay,
          dayBasedRepetitionRule:
              DayBasedRepetitionRuleCreateNestedManyWithoutEventInput(
                  createMany:
                      DayBasedRepetitionRuleCreateManyEventInputEnvelope(
                          data: PrismaUnion.$2(event.dayBasedRepetitionRules
                              .map((rule) =>
                                  DayBasedRepetitionRuleCreateManyEventInput(
                                    repeatAfterDays: rule.repeatAfterDays,
                                  ))))),
          monthBasedRepetitionRule:
              MonthBasedRepetitionRuleCreateNestedManyWithoutEventInput(
                  createMany:
                      MonthBasedRepetitionRuleCreateManyEventInputEnvelope(
                          data: PrismaUnion.$2(event.monthBasedRepetitionRules
                              .map((rule) =>
                                  MonthBasedRepetitionRuleCreateManyEventInput(
                                    repeatAfterMonths: rule.repeatAfterMonths,
                                    dayIndex: rule
                                        .monthBasedRepetitionRuleBase.dayIndex,
                                    weekIndex: rule.monthBasedRepetitionRuleBase
                                                .weekIndex !=
                                            null
                                        ? PrismaUnion.$1(rule
                                            .monthBasedRepetitionRuleBase
                                            .weekIndex!)
                                        : const PrismaUnion.$2(PrismaNull()),
                                    countFromEnd: rule
                                        .monthBasedRepetitionRuleBase
                                        .countFromEnd,
                                  ))))),
          user: UserCreateNestedOneWithoutEventSettingInput(
            connect: UserWhereUniqueInput(id: userId),
          ),
        )),
        include: _include,
      );

  Future<void> create(
    int userId,
    EventSetting event, {
    bool reload = true,
  }) async {
    final created = await _create(prisma, userId, event);
    if (reload) _stream.emitInsertion([created.toAppModel()]);
  }

  Future<void> update(int userId, EventSetting event) async {
    await prisma.$transaction((tx) async {
      await tx.eventSetting.delete(
        where: EventSettingWhereUniqueInput(id: event.id),
        include: _include,
      );
      await _create(tx, userId, event);
    });
    await loadUserSettings(userId);
  }

  Future<void> deleteByIds(List<int> ids) async =>
      _stream.emitDeletion((await deleteManyAndReturn(
              ids,
              (tx, id) => tx.eventSetting.delete(
                    where: EventSettingWhereUniqueInput(id: id),
                    include: _include,
                  )))
          .map((d) => d.toAppModel())
          .toList());

  Future<void> moveEventsToNewStartDate(
    int userId,
    List<EventSetting> newEvents,
    List<int> idsOfEventsToDelete,
  ) async {
    await prisma.$transaction((tx) async {
      for (final event in newEvents) {
        await _create(tx, userId, event);
      }
      await tx.eventSetting.deleteMany(
        where: EventSettingWhereInput(
          id: PrismaUnion.$1(
            IntFilter(
              $in: idsOfEventsToDelete,
            ),
          ),
        ),
      );
    });
    // reload all events
    await loadUserSettings(userId);
  }

  ContextDependentListStream<EventSetting> get stream => _stream;
}
