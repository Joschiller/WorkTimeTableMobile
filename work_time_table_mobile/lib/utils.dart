import 'package:work_time_table_mobile/app_error.dart';

extension IsBlank on String {
  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => trim().isNotEmpty;
}

/// Run an action after validating its preconditions.
/// Use this method, if any of the preconditions contains async calls. - Prefer to use [validateAndRun].
Future<T> validateAndRunAsync<T>(
  List<Future<AppError?> Function()> validations,
  Future<T> Function() action,
) async {
  for (final v in validations) {
    final err = await v();
    if (err != null) {
      return Future.error(err);
    }
  }
  return action();
}

/// Run an action after validating its preconditions.
/// Use this method, if none of the preconditions contains async calls.
T validateAndRun<T>(
  List<AppError? Function()> validations,
  T Function() action,
) {
  for (final v in validations) {
    final err = v();
    if (err != null) {
      throw err;
    }
  }
  return action();
}
