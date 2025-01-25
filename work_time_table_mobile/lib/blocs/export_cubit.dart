import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/display_snackbar.dart';
import 'package:work_time_table_mobile/services/export_service.dart';

class ExportCubit extends Cubit<Null> {
  ExportCubit(this._exportService) : super(null);

  final ExportService _exportService;

  Future<void> exportCurrentUser() => _exportService
      .exportCurrentUser()
      .then((_) => displaySnackbar('Export finished!'));

  Future<void> import() => _exportService
      .import()
      .then((_) => displaySnackbar('Import successful!'));
}
