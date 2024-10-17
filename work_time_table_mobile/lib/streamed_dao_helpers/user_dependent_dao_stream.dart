import 'package:work_time_table_mobile/streamed_dao_helpers/dao_stream.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/user_dependent_value.dart';

class UserDependentDaoStream<T> extends DaoStream<UserDependentValue<T>> {
  UserDependentDaoStream() : super(NoUserValue());
}
