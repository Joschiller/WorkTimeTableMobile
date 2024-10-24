import 'package:work_time_table_mobile/stream_helpers/cached_stream.dart';

class StreamableService {
  void prepareListen<T>(
    CachedStream<T> sourceStream,
    CachedStream<T> targetStream,
  ) {
    targetStream.emitReload(sourceStream.state);
    sourceStream.stream.listen(targetStream.emitReload);
  }

  void prepareComplexListen<T>(
    List<CachedStream> sourceStreams,
    T Function() generateNext,
    CachedStream<T> targetStream,
  ) {
    targetStream.emitReload(generateNext());
    for (var sourceStream in sourceStreams) {
      sourceStream.stream
          .listen((data) => targetStream.emitReload(generateNext()));
    }
  }
}
