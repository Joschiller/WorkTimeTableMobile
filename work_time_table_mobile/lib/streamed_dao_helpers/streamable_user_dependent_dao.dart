import 'package:work_time_table_mobile/streamed_dao_helpers/streamable_dao.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/user_dependent_value.dart';

abstract class StreamableUserDependentDao<T>
    extends StreamableDao<UserDependentValue<T>> {}
