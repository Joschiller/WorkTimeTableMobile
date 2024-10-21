import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/daos/mapper/day_value_mapper.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/prisma.dart';
import 'package:work_time_table_mobile/stream_helpers/context/list/context_dependent_list_streamable.dart';
import 'package:work_time_table_mobile/stream_helpers/context/list/context_dependent_list_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

final _stream = ContextDependentListStream<DayValue>();

class DayValueDao implements ContextDependentListStreamable<DayValue> {
  const DayValueDao();

  Future<void> loadUserValues(int? userId) async {
    if (userId == null) {
      _stream.emitReload(NoContextValue());
      return;
    }
    final values = await prisma.dayValue.findMany(
      where: DayValueWhereInput(userId: PrismaUnion.$2(userId)),
    );
    _stream
        .emitReload(ContextValue(values.map((v) => v.toAppModel()).toList()));
  }

  Future<void> upsert(int userId, DayValue value) async {
    final updated = await prisma.dayValue.upsert(
      where: DayValueWhereUniqueInput(
        userIdDate: DayValueUserIdDateCompoundUniqueInput(
          userId: userId,
          date: value.date,
        ),
      ),
      create: PrismaUnion.$1(DayValueCreateInput(
        date: value.date,
        firstHalfMode: value.firstHalfMode.name,
        secondHalfMode: value.secondHalfMode.name,
        workTimeStart: value.workTimeStart,
        workTimeEnd: value.workTimeEnd,
        breakDuration: value.breakDuration,
        user: UserCreateNestedOneWithoutDayValueInput(
          connect: UserWhereUniqueInput(id: userId),
        ),
      )),
      update: PrismaUnion.$1(DayValueUpdateInput(
        firstHalfMode: PrismaUnion.$1(value.firstHalfMode.name),
        secondHalfMode: PrismaUnion.$1(value.secondHalfMode.name),
        workTimeStart: PrismaUnion.$1(value.workTimeStart),
        workTimeEnd: PrismaUnion.$1(value.workTimeEnd),
        breakDuration: PrismaUnion.$1(value.breakDuration),
      )),
    );
    _stream.emitUpdate([updated.toAppModel()]);
  }

  Future<void> deleteByUserIdAndDates(int userId, List<DateTime> dates) async {
    final deleted = <prisma_model.DayValue>[];
    await prisma.$transaction(
      (prisma) async {
        for (final date in dates) {
          final del = await prisma.dayValue.delete(
            where: DayValueWhereUniqueInput(
              userIdDate: DayValueUserIdDateCompoundUniqueInput(
                userId: userId,
                date: date,
              ),
            ),
          );
          if (del != null) {
            deleted.add(del);
          }
        }
      },
    );
    _stream.emitDeletion(deleted.map((d) => d.toAppModel()).toList());
  }

  @override
  ContextDependentValue<List<DayValue>> get data => _stream.state;
  @override
  Stream<ContextDependentValue<List<DayValue>>> get stream => _stream.stream;
}
