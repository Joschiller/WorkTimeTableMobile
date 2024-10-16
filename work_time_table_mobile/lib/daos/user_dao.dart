import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/daos/mapper/user_mapper.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/list_dao_stream.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/streamable_list_dao.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/prisma.dart';

final _stream = ListDaoStream<User>([]);

class UserDao implements StreamableListDao<User> {
  const UserDao();

  Future<void> loadData() async {
    final users = await prisma.user.findMany();
    _stream.emitReload(users.map((u) => u.toAppModel()).toList());
  }

  Future<void> create(String name) async {
    final created = await prisma.user.create(
        data: PrismaUnion.$1(
      UserCreateInput(
        name: name,
        currentlySelected: false,
        defaultWorkTimeStart: 0,
        defaultWorkTimeEnd: 0,
        defaultMandatoryWorkTimeStart: 0,
        defaultMandatoryWorkTimeEnd: 0,
        defaultBreakDuration: 0,
        targetWorkTimePerWeek: 0,
      ),
    ));
    _stream.emitInsertion([created.toAppModel()]);
  }

  Future<void> renameById(int id, String newName) async {
    final updated = await prisma.user.update(
      data: PrismaUnion.$1(UserUpdateInput(name: PrismaUnion.$1(newName))),
      where: UserWhereUniqueInput(id: id),
    );
    if (updated != null) {
      _stream.emitUpdate([updated.toAppModel()]);
    }
  }

  Future<void> deleteById(int id) async {
    final deleted = await prisma.user.delete(
      where: UserWhereUniqueInput(id: id),
    );
    if (deleted != null) {
      _stream.emitDeletion([deleted.toAppModel()]);
    }
  }

  @override
  List<User> get data => _stream.state;
  @override
  Stream<List<User>> get stream => _stream.stream;
}
