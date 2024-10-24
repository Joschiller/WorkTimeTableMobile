import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/app_error.dart';

typedef ErrorCubitState = List<AppError>;

class ErrorCubit extends Cubit<ErrorCubitState> {
  ErrorCubit() : super([]);

  static AppError? getCurrentError(ErrorCubitState state) => state.firstOrNull;

  void queueError(AppError error) => emit([...state, error]);

  void popError() => emit(state.skip(1).toList());
}
