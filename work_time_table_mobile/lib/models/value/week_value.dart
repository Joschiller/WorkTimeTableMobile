import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;
import 'package:work_time_table_mobile/streamed_dao_helpers/identifiable.dart';

class WeekValue implements Identifiable {
  final DateTime weekStartDate;

  final int targetTime;

  WeekValue({required this.weekStartDate, required this.targetTime});
  WeekValue.fromPrismaModel(prisma_model.WeekValue weekValue)
      : this(
          weekStartDate: weekValue.weekStartDate!,
          targetTime: weekValue.targetTime!,
        );

  @override
  get identity => weekStartDate;
}
