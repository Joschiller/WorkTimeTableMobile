import 'dart:async';

class StreamIdentity<T> {
  final String id;
  final Stream<T> stream;

  StreamIdentity(this.id, this.stream);
}

class MergedStreamValue<T> {
  final StreamIdentity<T> streamIdentity;
  final T data;

  MergedStreamValue(this.streamIdentity, this.data);
}

Stream<MergedStreamValue> mergeStream(List<StreamIdentity> streams) {
  final controller = StreamController<MergedStreamValue>();

  for (var stream in streams) {
    stream.stream
        .listen((data) => controller.add(MergedStreamValue(stream, data)));
  }

  return controller.stream;
}
