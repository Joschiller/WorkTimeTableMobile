import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/daos/mapper/user_mapper.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/prisma.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/streamable_user_dependent_dao.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/user_dependent_dao_stream.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/user_dependent_value.dart';

final _stream = UserDependentDaoStream<User>();

class CurrentUserDao implements StreamableUserDependentDao<User> {
  Future<void> loadData() async {
    final user = await prisma.user.findFirst(
      where: const UserWhereInput(
        currentlySelected: PrismaUnion.$2(true),
      ),
    );
    _stream.emitReload(
        user != null ? UserValue(user.toAppModel()) : NoUserValue());
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
  UserDependentValue<User> get data => _stream.state;

  @override
  Stream<UserDependentValue<User>> get stream => _stream.stream;
}
