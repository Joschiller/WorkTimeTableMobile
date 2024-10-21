import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/utils.dart';

class UserService {
  UserService(
    this.userDao,
    this.currentUserDao,
  );

  final UserDao userDao;
  final CurrentUserDao currentUserDao;

  Future<void> loadData() async {
    await userDao.loadData();
    await currentUserDao.loadData();
  }

  Future<void> selectUser(int id) => validateAndRun(
        [
          () => !userDao.data.any((u) => u.id == id)
              ? AppError.service_user_unknownUser
              : null,
        ],
        () => currentUserDao.setSelectedUser(id),
      );

  Future<void> addUser(String name) => validateAndRun(
        [
          () => name.isBlank ? AppError.service_user_invalidName : null,
          () => userDao.data.any((user) => user.name == name)
              ? AppError.service_user_duplicateName
              : null,
        ],
        () => userDao.create(name),
      );

  Future<void> renameUser(int id, String newName) => validateAndRun(
        [
          () => newName.isBlank ? AppError.service_user_invalidName : null,
          () =>
              userDao.data.any((user) => user.id != id && user.name == newName)
                  ? AppError.service_user_duplicateName
                  : null,
        ],
        () => userDao.renameById(id, newName),
      );

  Future<void> deleteUser(int id, bool isConfirmed) => validateAndRun(
        [
          () => runContextDependentAction(
                currentUserDao.data,
                () => null,
                (value) => value.id == id
                    ? AppError.service_user_forbiddenDeletion
                    : null,
              ),
          () => !isConfirmed ? AppError.service_user_unconfirmedDeletion : null,
        ],
        () => userDao.deleteById(id),
      );
}
