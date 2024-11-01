import 'package:work_time_table_mobile/prisma.dart';

Future<List<D>> deleteManyAndReturn<T, D>(
  List<T> itemsToDelete,
  Future<D?> Function(T item) doDelete,
) async {
  final deleted = <D>[];
  await prisma.$transaction(
    (prisma) async {
      for (final item in itemsToDelete) {
        final del = await doDelete(item);
        if (del != null) {
          deleted.add(del);
        }
      }
    },
  );
  return deleted;
}
