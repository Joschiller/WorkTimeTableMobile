import 'package:work_time_table_mobile/validator.dart';

/// Run an action after validating its preconditions.
/// Use this method, if none of the preconditions contains async calls.
R validateAndRun<T, R>(
  Validator<T> validator,
  T item,
  R Function() action,
) {
  final err = validator.validate(item);
  if (err != null) {
    throw err;
  }
  return action();
}

/// Run an action after validating its preconditions.
/// Use this method, if any of the preconditions contains async calls. - Prefer to use [validateAndRun].
Future<R> validateAndRunAsync<T, R>(
  AsyncValidator<T> validator,
  T item,
  Future<R> Function() action,
) async {
  final err = await validator.validate(item);
  if (err != null) {
    return Future.error(err);
  }
  return action();
}
