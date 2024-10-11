import 'package:work_time_table_mobile/streamed_dao_helpers/identifiable.dart';

class User implements Identifiable {
  final int id;
  final String name;

  User({required this.id, required this.name});

  @override
  get identity => id;
}
