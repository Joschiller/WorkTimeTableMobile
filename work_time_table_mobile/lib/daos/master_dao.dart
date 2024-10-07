import 'package:work_time_table_mobile/prisma.dart';

class MasterDao {
  const MasterDao();

  Future<List<({String name, String sql})>> selectTables() async => [
        for (final {
              'name': name as String,
              'sql': sql as String,
            } in (await prisma.$raw
                .query('SELECT name, sql FROM sqlite_master;')))
          (
            name: name,
            sql: sql,
          ),
      ];
}
