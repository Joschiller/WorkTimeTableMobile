import 'dart:async';

import 'package:work_time_table_mobile/stream_helpers/cached_stream.dart';

class StreamableService {
  final _subscriptions = <StreamSubscription>[];

  void registerSubscription(StreamSubscription subscription) =>
      _subscriptions.add(subscription);

  void prepareListen<T>(
    CachedStream<T> sourceStream,
    CachedStream<T> targetStream,
  ) {
    targetStream.emitReload(sourceStream.state);
    _subscriptions.add(sourceStream.stream.listen(targetStream.emitReload));
  }

  void prepareComplexListen<T>(
    List<CachedStream> sourceStreams,
    T Function() generateNext,
    CachedStream<T> targetStream,
  ) {
    targetStream.emitReload(generateNext());
    _subscriptions.addAll(sourceStreams
        .map((sourceStream) => sourceStream.stream
            .listen((data) => targetStream.emitReload(generateNext())))
        .toList());
  }

  void close() {
    for (var s in _subscriptions) {
      s.cancel();
    }
  }
}
