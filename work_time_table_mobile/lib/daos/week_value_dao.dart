import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/daos/mapper/week_value_mapper.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/list_dao_stream.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/streamable_list_dao.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/prisma.dart';

final initialWeekValueValue = <WeekValue>[];

final _stream = ListDaoStream<WeekValue>(initialWeekValueValue);

class WeekValueDao implements StreamableListDao<WeekValue> {
  const WeekValueDao();

  Future<void> loadUserValues(int? userId) async {
    if (userId == null) {
      _stream.emitReload(initialWeekValueValue);
      return;
    }
    final values = await prisma.weekValue.findMany(
      where: WeekValueWhereInput(userId: PrismaUnion.$2(userId)),
    );
    _stream.emitReload(values.map((v) => v.toAppModel()).toList());
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
  List<WeekValue> get data => _stream.state;
  @override
  Stream<List<WeekValue>> get stream => _stream.stream;
}
