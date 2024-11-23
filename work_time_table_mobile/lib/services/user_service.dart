import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/stream_helpers/list/list_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/streamable_service.dart';
import 'package:work_time_table_mobile/utils.dart';
import 'package:work_time_table_mobile/validate_and_run.dart';
import 'package:work_time_table_mobile/validator.dart';

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

  static final Validator<({int id, UserDao userDao})> _userKnownValidator =
      Validator([
    (item) => !item.userDao.stream.state.any((u) => u.id == item.id)
        ? AppError.service_user_unknownUser
        : null,
  ]);

  static final Validator<({String name, List<String> occupiedNames})>
      userNameValidator = Validator([
    (item) => item.name.isBlank ? AppError.service_user_invalidBlankName : null,
    (item) => item.occupiedNames.contains(item.name.trim())
        ? AppError.service_user_duplicateName
        : null,
  ]);

  static final Validator<
      ({
        List<int> idsOfUsersToDelete,
        CurrentUserDao currentUserDao,
      })> _usersDeletableValidator = Validator([
    (item) => runContextDependentAction(
          item.currentUserDao.stream.state,
          () => null,
          (value) => item.idsOfUsersToDelete.any((id) => value.id == id)
              ? AppError.service_user_forbiddenDeletion
              : null,
        ),
  ]);

  Future<void> loadData() async {
    await _userDao.loadData();
    await _currentUserDao.loadData();
  }

  Future<void> selectUser(int id) => validateAndRun(
        _userKnownValidator,
        (id: id, userDao: _userDao),
        () => _currentUserDao.setSelectedUser(id),
      );

  Future<void> addUser(String name) => validateAndRun(
        userNameValidator,
        (
          name,
          _userDao.stream.state.map((u) => u.name).toList(),
        ),
        () => _userDao.stream.state.isEmpty
            ? _userDao.createFirstUser(name.trim()).then(
                  (value) => _currentUserDao.loadData(),
                )
            : _userDao.create(name.trim()),
      );

  Future<void> renameUser(int id, String newName) => validateAndRun(
        _userKnownValidator.plus(
          userNameValidator,
        ),
        (
          (id, _userDao),
          (
            newName,
            _userDao.stream.state
                .where((u) => u.id != id)
                .map((u) => u.name)
                .toList(),
          ),
        ),
        () => _userDao.renameById(id, newName.trim()),
      );

  Future<void> deleteUsers(List<int> ids, bool isConfirmed) => validateAndRun(
        _usersDeletableValidator.plus(getIsConfirmedValidator(
          AppError.service_user_unconfirmedDeletion,
        )),
        ((ids, _currentUserDao), isConfirmed),
        () => _userDao.deleteByIds(ids),
      );
}
