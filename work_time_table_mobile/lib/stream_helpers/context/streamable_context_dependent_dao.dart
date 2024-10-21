import 'package:work_time_table_mobile/stream_helpers/streamable.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

abstract class StreamableContextDependentDao<T>
    extends Streamable<ContextDependentValue<T>> {}
