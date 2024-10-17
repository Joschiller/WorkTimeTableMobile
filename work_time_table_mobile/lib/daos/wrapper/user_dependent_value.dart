sealed class UserDependentValue<T> {}

class NoUserValue<T> extends UserDependentValue<T> {}

class UserValue<T> extends UserDependentValue<T> {
  UserValue(this.value);

  final T value;
}
