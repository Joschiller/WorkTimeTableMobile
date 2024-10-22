import 'package:work_time_table_mobile/stream_helpers/cached_stream.dart';

class StreamableService {
  void prepareListen<T>(
    CachedStream<T> daoStream,
    CachedStream<T> serviceStream,
  ) {
    serviceStream.emitReload(daoStream.state);
    daoStream.stream.listen(serviceStream.emitReload);
  }

  void prepareComplexListen<T>(
    List<CachedStream> daoStreams,
    T Function() generateNext,
    CachedStream<T> serviceStream,
  ) {
    serviceStream.emitReload(generateNext());
    for (var daoStream in daoStreams) {
      daoStream.stream
          .listen((data) => serviceStream.emitReload(generateNext()));
    }
  }
}
