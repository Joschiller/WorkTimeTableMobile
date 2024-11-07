import 'package:work_time_table_mobile/app_error.dart';

class Validator {
  Validator(this.validations);

  final List<AppError? Function()> validations;

  bool get isValid => validate() == null;

  AppError? validate() {
    for (final v in validations) {
      final err = v();
      if (err != null) {
        return err;
      }
    }
    return null;
  }

  List<AppError> validateAll() =>
      validations.map((v) => v()).whereType<AppError>().toList();
}

class AsyncValidator {
  AsyncValidator(this.validations);

  final List<Future<AppError?> Function()> validations;

  Future<bool> get isValid async => (await validate()) == null;

  Future<AppError?> validate() async {
    for (final v in validations) {
      final err = await v();
      if (err != null) {
        return err;
      }
    }

    return null;
  }

  Future<List<AppError>> validateAll() async {
    final errors = <AppError>[];
    for (final v in validations) {
      final err = await v();
      if (err != null) {
        errors.add(err);
      }
    }
    return errors;
  }
}
