sealed class UserDependentValue<T> {}

class NoUserValue<T> extends UserDependentValue<T> {}

class UserValue<T> extends UserDependentValue<T> {
  UserValue(this.value);

  final T value;
}

T runUserDependentAction<T, U>(
  UserDependentValue<U> user,
  T Function() noUserAction,
  T Function(U value) userAction,
) =>
    switch (user) {
      NoUserValue() => noUserAction(),
      UserValue(value: var userValue) => userAction(userValue),
    };
