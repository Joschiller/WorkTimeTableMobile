import 'dart:async';

class CachedStream<T> {
  final _streamController = StreamController<T>.broadcast();
  T _state;
  T get state => _state;
  Stream<T> get stream => _streamController.stream;

  CachedStream(this._state) {
    stream.listen((newState) => _state = newState);
  }

  /// Pushes a new state to the stream.
  void emitReload(T data) => _streamController.add(data);
}
