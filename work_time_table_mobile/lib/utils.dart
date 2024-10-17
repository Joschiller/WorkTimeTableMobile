import 'package:work_time_table_mobile/app_error.dart';

extension IsBlank on String {
  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => trim().isNotEmpty;
}

Future<void> validateAndRun(
  List<AppError? Function()> validations,
  Future<void> Function() action,
) async {
  for (final v in validations) {
    final err = v();
    if (err != null) {
      return Future.error(err);
    }
  }
  return action();
}
