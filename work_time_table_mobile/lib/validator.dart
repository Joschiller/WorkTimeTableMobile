import 'package:work_time_table_mobile/app_error.dart';

class Validator<T> {
  const Validator(this.validations);

  final List<AppError? Function(T item)> validations;

  /// Addition for validators of same type.
  operator +(Validator<T> other) => Validator([
        ...validations,
        ...other.validations,
      ]);

  /// Addition for validators of differing type.
  Validator<({T item1, R item2})> plus<R>(Validator<R> other) => Validator([
        ...validations.map((e) => (item) => e(item.item1)),
        ...other.validations.map((e) => (item) => e(item.item2)),
      ]);

  bool isValid(T item) => validate(item) == null;

  AppError? validate(T item) {
    for (final v in validations) {
      final err = v(item);
      if (err != null) {
        return err;
      }
    }
    return null;
  }

  List<AppError> validateAll(T item) =>
      validations.map((v) => v(item)).whereType<AppError>().toList();
}

class AsyncValidator<T> {
  const AsyncValidator(this.validations);

  final List<Future<AppError?> Function(T item)> validations;

  /// Addition for validators of same type.
  operator +(AsyncValidator<T> other) => AsyncValidator([
        ...validations,
        ...other.validations,
      ]);

  /// Addition for validators of differing type.
  AsyncValidator<({T item1, R item2})> plus<R>(AsyncValidator<R> other) =>
      AsyncValidator([
        ...validations.map((e) => (item) async => e(item.item1)),
        ...other.validations.map((e) => (item) async => e(item.item2)),
      ]);

  Future<bool> isValid(T item) async => (await validate(item)) == null;

  Future<AppError?> validate(T item) async {
    for (final v in validations) {
      final err = await v(item);
      if (err != null) {
        return err;
      }
    }

    return null;
  }

  Future<List<AppError>> validateAll(T item) async {
    final errors = <AppError>[];
    for (final v in validations) {
      final err = await v(item);
      if (err != null) {
        errors.add(err);
      }
    }
    return errors;
  }
}

Validator getIsConfirmedValidator(
  AppError ifNotConfirmedError,
) =>
    Validator<bool>([
      (isConfirmed) => !isConfirmed ? ifNotConfirmedError : null,
    ]);
