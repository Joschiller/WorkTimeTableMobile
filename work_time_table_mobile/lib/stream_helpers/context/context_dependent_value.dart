sealed class ContextDependentValue<T> {}

class NoContextValue<T> extends ContextDependentValue<T> {}

class ContextValue<T> extends ContextDependentValue<T> {
  ContextValue(this.value);

  final T value;
}

T runContextDependentAction<T, U>(
  ContextDependentValue<U> context,
  T Function() noContextAction,
  T Function(U value) contextAction,
) =>
    switch (context) {
      NoContextValue() => noContextAction(),
      ContextValue(value: var contextValue) => contextAction(contextValue),
    };
