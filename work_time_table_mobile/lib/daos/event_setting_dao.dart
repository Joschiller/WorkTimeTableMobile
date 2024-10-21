import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/daos/mapper/event_setting_mapper.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/prisma.dart';
import 'package:work_time_table_mobile/stream_helpers/context/list/context_dependent_list_streamable.dart';
import 'package:work_time_table_mobile/stream_helpers/context/list/context_dependent_list_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

final _stream = ContextDependentListStream<EventSetting>();

class EventSettingDao implements ContextDependentListStreamable<EventSetting> {
  const EventSettingDao();

  Future<void> loadUserSettings(int? userId) async {
    if (userId == null) {
      _stream.emitReload(NoContextValue());
      return;
    }
    final settings = await prisma.eventSetting.findMany(
      where: EventSettingWhereInput(userId: PrismaUnion.$2(userId)),
      include: const EventSettingInclude(
        dayBasedRepetitionRule: PrismaUnion.$1(true),
        monthBasedRepetitionRule: PrismaUnion.$1(true),
      ),
    );
    _stream
        .emitReload(ContextValue(settings.map((s) => s.toAppModel()).toList()));
  }

  Future<void> create(int userId, EventSetting event) async {
    final created = await prisma.eventSetting.create(
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
                createMany: DayBasedRepetitionRuleCreateManyEventInputEnvelope(
                    data: PrismaUnion.$2(event.dayBasedRepetitionRules.map(
                        (rule) => DayBasedRepetitionRuleCreateManyEventInput(
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
                                  dayIndex: rule.dayIndex,
                                  weekIndex: rule.weekIndex != null
                                      ? PrismaUnion.$1(rule.weekIndex!)
                                      : const PrismaUnion.$2(PrismaNull()),
                                  countFromEnd: rule.countFromEnd,
                                ))))),
        user: UserCreateNestedOneWithoutEventSettingInput(
          connect: UserWhereUniqueInput(id: userId),
        ),
      )),
      include: const EventSettingInclude(
        dayBasedRepetitionRule: PrismaUnion.$1(true),
        monthBasedRepetitionRule: PrismaUnion.$1(true),
      ),
    );
    _stream.emitInsertion([created.toAppModel()]);
  }

  Future<void> deleteById(int id) async {
    final deleted = await prisma.eventSetting.delete(
      where: EventSettingWhereUniqueInput(id: id),
      include: const EventSettingInclude(
        dayBasedRepetitionRule: PrismaUnion.$1(true),
        monthBasedRepetitionRule: PrismaUnion.$1(true),
      ),
    );
    if (deleted != null) {
      _stream.emitDeletion([deleted.toAppModel()]);
    }
  }

  @override
  ContextDependentValue<List<EventSetting>> get data => _stream.state;
  @override
  Stream<ContextDependentValue<List<EventSetting>>> get stream =>
      _stream.stream;
}
