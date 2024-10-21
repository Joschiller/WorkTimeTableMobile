import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/services/user_service.dart';

typedef UserCubitState = List<User>;

class UserCubit extends Cubit<UserCubitState> {
  UserCubit(this._userService) : super([]) {
    _userService.userStream.listen(emit);
  }

  final UserService _userService;

  Future<void> addUser(String name) => _userService.addUser(name);

  Future<void> renameUser(int id, String newName) =>
      _userService.renameUser(id, newName);

  Future<void> deleteUser(int id, bool isConfirmed) =>
      _userService.deleteUser(id, isConfirmed);
}
