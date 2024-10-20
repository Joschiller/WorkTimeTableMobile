import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/context/context_dependent_value.dart';

typedef CurrentUserCubitState = User?;

class CurrentUserCubit extends Cubit<CurrentUserCubitState> {
  CurrentUserCubit(this.userService) : super(null) {
    userService.currentUserDao.stream
        .listen((value) => runContextDependentAction(
              value,
              () => emit(null),
              emit,
            ));
    userService.loadData();
  }

  UserService userService;

  Future<void> selectUser(int id) => userService.selectUser(id);
}
