import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/services/user_service.dart';

typedef UserCubitState = List<User>;

class UserCubit extends Cubit<UserCubitState> {
  UserCubit(this.userService) : super([]) {
    userService.userDao.stream.listen(emit);
  }

  UserService userService;

  Future<void> addUser(String name) => userService.addUser(name);

  Future<void> renameUser(int id, String newName) =>
      userService.renameUser(id, newName);

  Future<void> deleteUser(int id, bool isConfirmed) =>
      userService.deleteUser(id, isConfirmed);
}
