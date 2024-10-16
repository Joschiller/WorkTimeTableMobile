import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/daos/mapper/user_mapper.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/prisma.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/dao_stream.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/streamable_dao.dart';

final _stream = DaoStream<User?>(null);

class CurrentUserDao implements StreamableDao<User?> {
  Future<void> loadData() async {
    final user = await prisma.user.findFirst(
      where: const UserWhereInput(
        currentlySelected: PrismaUnion.$2(true),
      ),
    );
    _stream.emitReload(user?.toAppModel());
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

  @override
  User? get data => _stream.state;

  @override
  Stream<User?> get stream => _stream.stream;
}
