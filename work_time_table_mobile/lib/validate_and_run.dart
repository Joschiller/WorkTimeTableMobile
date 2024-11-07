import 'package:work_time_table_mobile/validator.dart';

/// Run an action after validating its preconditions.
/// Use this method, if none of the preconditions contains async calls.
T validateAndRun<T>(
  Validator validator,
  T Function() action,
) {
  final err = validator.validate();
  if (err != null) {
    throw err;
  }
  return action();
}

extension DateTimeToDay on DateTime {
  DateTime toDay() => DateTime(year, month, day);
}

/// Run an action after validating its preconditions.
/// Use this method, if any of the preconditions contains async calls. - Prefer to use [validateAndRun].
Future<T> validateAndRunAsync<T>(
  AsyncValidator validator,
  Future<T> Function() action,
) async {
  final err = await validator.validate();
  if (err != null) {
    return Future.error(err);
  }
  return action();
}
