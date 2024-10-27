import 'dart:async';

import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_cubit.dart';

class CurrentUserCubit extends ContextDependentCubit<User> {
  late StreamSubscription _subscription;

  CurrentUserCubit(this._userService) : super() {
    _subscription = _userService.currentUserStream.stream.listen(emit);
    _userService.loadData();
  }

  final UserService _userService;

  Future<void> selectUser(int id) => _userService.selectUser(id);

  @override
  Future<void> close() {
    _subscription.cancel();
    _userService.close();
    return super.close();
  }
}
