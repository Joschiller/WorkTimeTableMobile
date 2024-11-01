import 'package:work_time_table_mobile/_generated_prisma_client/client.dart';
import 'package:work_time_table_mobile/prisma.dart';

Future<List<D>> deleteManyAndReturn<T, D>(
  List<T> itemsToDelete,
  Future<D?> Function(PrismaClient tx, T item) doDelete,
) async {
  final deleted = <D>[];
  await prisma.$transaction(
    (tx) async {
      for (final item in itemsToDelete) {
        final del = await doDelete(tx, item);
        if (del != null) {
          deleted.add(del);
        }
      }
    },
  );
  return deleted;
}
