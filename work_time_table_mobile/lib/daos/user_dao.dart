import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/daos/mapper/user_mapper.dart';
import 'package:work_time_table_mobile/stream_helpers/dao_deletion_helper.dart';
import 'package:work_time_table_mobile/stream_helpers/list/list_stream.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/prisma.dart';

final _stream = ListStream<User>([]);

class UserDao {
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

  Future<void> deleteByIds(List<int> ids) async =>
      _stream.emitDeletion((await deleteManyAndReturn(
              ids,
              (tx, id) => tx.user.delete(
                    where: UserWhereUniqueInput(id: id),
                  )))
          .map((d) => d.toAppModel())
          .toList());

  ListStream<User> get stream => _stream;
}
