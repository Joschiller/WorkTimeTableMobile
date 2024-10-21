import 'package:work_time_table_mobile/stream_helpers/cached_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/streamable.dart';

class StreamableService {
  void prepareListen<T>(Streamable<T> dao, CachedStream<T> serviceStream) {
    serviceStream.emitReload(dao.data);
    dao.stream.listen(serviceStream.emitReload);
  }
}
