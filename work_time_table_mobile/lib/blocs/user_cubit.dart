import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/services/user_service.dart';

class UserCubit extends Cubit<List<User>> {
  UserCubit(this._userService) : super([]) {
    _userService.userStream.stream.listen(emit);
  }

  final UserService _userService;

  Future<void> addUser(String name) => _userService.addUser(name);

  Future<void> renameUser(int id, String newName) =>
      _userService.renameUser(id, newName);

  Future<void> deleteUser(int id, bool isConfirmed) =>
      _userService.deleteUser(id, isConfirmed);

  Future<void> deleteUsers(List<int> ids, bool isConfirmed) =>
      _userService.deleteUsers(ids, isConfirmed);
}
