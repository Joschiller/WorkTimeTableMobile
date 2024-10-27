import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/daos/mapper/user_mapper.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/prisma.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

final _stream = ContextDependentStream<User>();

class CurrentUserDao {
  const CurrentUserDao();

  Future<void> loadData() async {
    final user = await prisma.user.findFirst(
      where: const UserWhereInput(
        currentlySelected: PrismaUnion.$2(true),
      ),
    );
    _stream.emitReload(
        user != null ? ContextValue(user.toAppModel()) : NoContextValue());
  }

  Future<void> setSelectedUser(int id) async {
    await prisma.$transaction((prisma) async {
      await prisma.user.updateMany(
        data: const PrismaUnion.$1(UserUpdateManyMutationInput(
          currentlySelected: PrismaUnion.$1(false),
        )),
      );
      await prisma.user.update(
        data: const PrismaUnion.$1(UserUpdateInput(
          currentlySelected: PrismaUnion.$1(true),
        )),
        where: UserWhereUniqueInput(id: id),
      );
    });
    await loadData();
  }

  ContextDependentStream<User> get stream => _stream;
}
