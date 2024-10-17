import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/daos/mapper/week_value_mapper.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/prisma.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/streamable_user_dependent_list_dao.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/user_dependent_list_dao_stream.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/user_dependent_value.dart';

final _stream = UserDependentListDaoStream<WeekValue>();

class WeekValueDao implements StreamableUserDependentListDao<WeekValue> {
  const WeekValueDao();

  Future<void> loadUserValues(int? userId) async {
    if (userId == null) {
      _stream.emitReload(NoUserValue());
      return;
    }
    final values = await prisma.weekValue.findMany(
      where: WeekValueWhereInput(userId: PrismaUnion.$2(userId)),
    );
    _stream.emitReload(UserValue(values.map((v) => v.toAppModel()).toList()));
  }

  Future<void> create(int userId, WeekValue value) async {
    final inserted = await prisma.weekValue.create(
        data: PrismaUnion.$1(WeekValueCreateInput(
      weekStartDate: value.weekStartDate,
      targetTime: value.targetTime,
      user: UserCreateNestedOneWithoutWeekValueInput(
        connect: UserWhereUniqueInput(id: userId),
      ),
    )));
    _stream.emitInsertion([inserted.toAppModel()]);
  }

  @override
  UserDependentValue<List<WeekValue>> get data => _stream.state;
  @override
  Stream<UserDependentValue<List<WeekValue>>> get stream => _stream.stream;
}
