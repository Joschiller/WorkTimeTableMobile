abstract class StreamableDao<T> {
  T get data;
  Stream<T> get stream;
}
