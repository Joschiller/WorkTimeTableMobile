import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/context/context_dependent_value.dart';

class ContextDependentCubit<T> extends Cubit<ContextDependentValue<T>> {
  ContextDependentCubit() : super(NoContextValue());
}
