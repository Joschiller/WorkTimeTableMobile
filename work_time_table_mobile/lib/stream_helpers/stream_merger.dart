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

  for (var identity in streams) {
    identity.stream
        .listen((data) => controller.add(MergedStreamValue(identity, data)));
  }

  return controller.stream;
}
