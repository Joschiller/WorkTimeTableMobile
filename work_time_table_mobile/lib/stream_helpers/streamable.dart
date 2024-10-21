abstract class Streamable<T> {
  T get data;
  Stream<T> get stream;
}
