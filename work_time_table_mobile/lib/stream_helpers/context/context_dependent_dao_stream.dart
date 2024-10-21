import 'package:work_time_table_mobile/stream_helpers/dao_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

class ContextDependentDaoStream<T> extends DaoStream<ContextDependentValue<T>> {
  ContextDependentDaoStream() : super(NoContextValue());
}
