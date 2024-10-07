import 'dart:async';

class DaoStream<T> {
  final _streamController = StreamController<T>.broadcast();
  T state;
  Stream<T> get stream => _streamController.stream;

  DaoStream(this.state) {
    stream.listen((newState) => state = newState);
  }

  /// Pushes a new state to the stream.
  void emitReload(T data) => _streamController.add(data);
}
