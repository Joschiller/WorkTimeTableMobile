import 'package:work_time_table_mobile/streamed_dao_helpers/streamable_dao.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/context/context_dependent_value.dart';

abstract class StreamableContextDependentDao<T>
    extends StreamableDao<ContextDependentValue<T>> {}
