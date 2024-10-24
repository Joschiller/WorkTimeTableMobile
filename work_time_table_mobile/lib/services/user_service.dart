import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/list/list_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/streamable_service.dart';
import 'package:work_time_table_mobile/utils.dart';

final _userStream = ListStream<User>([]);
final _currentUserStream = ContextDependentStream<User>();

class UserService extends StreamableService {
  UserService(
    this._userDao,
    this._currentUserDao,
  ) {
    prepareListen(_userDao.stream, _userStream);
    prepareListen(_currentUserDao.stream, _currentUserStream);
  }

  final UserDao _userDao;
  final CurrentUserDao _currentUserDao;

  ListStream<User> get userStream => _userStream;
  ContextDependentStream<User> get currentUserStream => _currentUserStream;

  Future<void> loadData() async {
    await _userDao.loadData();
    await _currentUserDao.loadData();
  }

  Future<void> selectUser(int id) => validateAndRun(
        [
          () => !_userDao.stream.state.any((u) => u.id == id)
              ? AppError.service_user_unknownUser
              : null,
        ],
        () => _currentUserDao.setSelectedUser(id),
      );

  Future<void> addUser(String name) => validateAndRun(
        [
          () => name.isBlank ? AppError.service_user_invalidName : null,
          () => _userDao.stream.state.any((user) => user.name == name)
              ? AppError.service_user_duplicateName
              : null,
        ],
        () => _userDao.create(name),
      );

  Future<void> renameUser(int id, String newName) => validateAndRun(
        [
          () => newName.isBlank ? AppError.service_user_invalidName : null,
          () => _userDao.stream.state
                  .any((user) => user.id != id && user.name == newName)
              ? AppError.service_user_duplicateName
              : null,
        ],
        () => _userDao.renameById(id, newName),
      );

  Future<void> deleteUser(int id, bool isConfirmed) => validateAndRun(
        [
          () => runContextDependentAction(
                _currentUserDao.stream.state,
                () => null,
                (value) => value.id == id
                    ? AppError.service_user_forbiddenDeletion
                    : null,
              ),
          () => !isConfirmed ? AppError.service_user_unconfirmedDeletion : null,
        ],
        () => _userDao.deleteById(id),
      );
}
