import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;
import 'package:work_time_table_mobile/streamed_dao_helpers/identifiable.dart';
import 'package:work_time_table_mobile/models/value/day_mode.dart';

class DayValue implements Identifiable {
  final DateTime date;

  final DayMode mode;
  final int workTimeStart;
  final int workTimeEnd;
  final int breakDuration;

  DayValue({
    required this.date,
    required this.mode,
    required this.workTimeStart,
    required this.workTimeEnd,
    required this.breakDuration,
  });
  DayValue.fromPrismaModel(prisma_model.DayValue dayValue)
      : this(
          date: dayValue.date!,
          mode: DayMode.values.firstWhere((d) => d.name == dayValue.mode),
          workTimeStart: dayValue.workTimeStart!,
          workTimeEnd: dayValue.workTimeEnd!,
          breakDuration: dayValue.breakDuration!,
        );

  @override
  get identity => date;
}
