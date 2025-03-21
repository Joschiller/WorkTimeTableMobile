import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/daos/mapper/week_value_mapper.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/prisma.dart';
import 'package:work_time_table_mobile/stream_helpers/context/list/context_dependent_list_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

final _stream = ContextDependentListStream<WeekValue>();

class WeekValueDao {
  const WeekValueDao();

  Future<void> loadUserValues(int? userId) async {
    if (userId == null) {
      _stream.emitReload(NoContextValue());
      return;
    }
    final values = await prisma.weekValue.findMany(
      where: WeekValueWhereInput(userId: PrismaUnion.$2(userId)),
    );
    _stream
        .emitReload(ContextValue(values.map((v) => v.toAppModel()).toList()));
  }

  Future<void> create(
    int userId,
    WeekValue value, {
    bool reload = true,
  }) async {
    final inserted = await prisma.weekValue.create(
        data: PrismaUnion.$1(WeekValueCreateInput(
      weekStartDate: value.weekStartDate,
      targetTime: value.targetTime,
      user: UserCreateNestedOneWithoutWeekValueInput(
        connect: UserWhereUniqueInput(id: userId),
      ),
    )));
    if (reload) _stream.emitInsertion([inserted.toAppModel()]);
  }

  ContextDependentListStream<WeekValue> get stream => _stream;
}
