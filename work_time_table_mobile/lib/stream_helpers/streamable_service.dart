import 'dart:async';

import 'package:work_time_table_mobile/stream_helpers/cached_stream.dart';

class StreamableService {
  StreamSubscription prepareListen<T>(
    CachedStream<T> sourceStream,
    CachedStream<T> targetStream,
  ) {
    targetStream.emitReload(sourceStream.state);
    return sourceStream.stream.listen(targetStream.emitReload);
  }

  List<StreamSubscription> prepareComplexListen<T>(
    List<CachedStream> sourceStreams,
    T Function() generateNext,
    CachedStream<T> targetStream,
  ) {
    targetStream.emitReload(generateNext());
    return sourceStreams
        .map((sourceStream) => sourceStream.stream
            .listen((data) => targetStream.emitReload(generateNext())))
        .toList();
  }
}
