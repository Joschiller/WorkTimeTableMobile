import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_cubit.dart';

class CurrentUserCubit extends ContextDependentCubit<User> {
  CurrentUserCubit(this.userService) : super() {
    userService.currentUserDao.stream.listen(emit);
    userService.loadData();
  }

  UserService userService;

  Future<void> selectUser(int id) => userService.selectUser(id);
}
