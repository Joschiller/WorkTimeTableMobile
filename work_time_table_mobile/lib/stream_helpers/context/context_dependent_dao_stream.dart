import 'package:work_time_table_mobile/stream_helpers/cached_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

class ContextDependentDaoStream<T>
    extends CachedStream<ContextDependentValue<T>> {
  ContextDependentDaoStream() : super(NoContextValue());
}
