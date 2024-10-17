import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/daos/mapper/day_value_mapper.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/prisma.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/streamable_user_dependent_list_dao.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/user_dependent_list_dao_stream.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/user_dependent_value.dart';

final _stream = UserDependentListDaoStream<DayValue>();

class DayValueDao implements StreamableUserDependentListDao<DayValue> {
  const DayValueDao();

  Future<void> loadUserValues(int? userId) async {
    if (userId == null) {
      _stream.emitReload(NoUserValue());
      return;
    }
    final values = await prisma.dayValue.findMany(
      where: DayValueWhereInput(userId: PrismaUnion.$2(userId)),
    );
    _stream.emitReload(UserValue(values.map((v) => v.toAppModel()).toList()));
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
        mode: value.mode.name,
        workTimeStart: value.workTimeStart,
        workTimeEnd: value.workTimeEnd,
        breakDuration: value.breakDuration,
        user: UserCreateNestedOneWithoutDayValueInput(
          connect: UserWhereUniqueInput(id: userId),
        ),
      )),
      update: PrismaUnion.$1(DayValueUpdateInput(
        mode: PrismaUnion.$1(value.mode.name),
        workTimeStart: PrismaUnion.$1(value.workTimeStart),
        workTimeEnd: PrismaUnion.$1(value.workTimeEnd),
        breakDuration: PrismaUnion.$1(value.breakDuration),
      )),
    );
    _stream.emitUpdate([updated.toAppModel()]);
  }

  Future<void> deleteByUserIdAndDate(int userId, DateTime date) async {
    final deleted = await prisma.dayValue.delete(
      where: DayValueWhereUniqueInput(
        userIdDate: DayValueUserIdDateCompoundUniqueInput(
          userId: userId,
          date: date,
        ),
      ),
    );
    if (deleted != null) {
      _stream.emitDeletion([deleted.toAppModel()]);
    }
  }

  @override
  UserDependentValue<List<DayValue>> get data => _stream.state;
  @override
  Stream<UserDependentValue<List<DayValue>>> get stream => _stream.stream;
}
