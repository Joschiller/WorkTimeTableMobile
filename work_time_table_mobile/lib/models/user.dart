import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;
import 'package:work_time_table_mobile/streamed_dao_helpers/identifiable.dart';

class User implements Identifiable {
  final int id;
  final String name;

  User({required this.id, required this.name});
  User.fromPrismaModel(prisma_model.User user)
      : this(
          id: user.id!,
          name: user.name!,
        );

  @override
  get identity => id;
}
