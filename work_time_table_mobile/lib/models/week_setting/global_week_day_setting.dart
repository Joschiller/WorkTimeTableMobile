import 'package:work_time_table_mobile/_generated_prisma_client/model.dart'
    as prisma_model;

class GlobalWeekDaySetting {
  final int defaultWorkTimeStart;
  final int defaultWorkTimeEnd;
  final int defaultMandatoryWorkTimeStart;
  final int defaultMandatoryWorkTimeEnd;
  final int defaultBreakDuration;

  GlobalWeekDaySetting({
    required this.defaultWorkTimeStart,
    required this.defaultWorkTimeEnd,
    required this.defaultMandatoryWorkTimeStart,
    required this.defaultMandatoryWorkTimeEnd,
    required this.defaultBreakDuration,
  });
  GlobalWeekDaySetting.fromPrismaModel(prisma_model.User user)
      : this(
          defaultWorkTimeStart: user.defaultWorkTimeStart!,
          defaultWorkTimeEnd: user.defaultWorkTimeEnd!,
          defaultMandatoryWorkTimeStart: user.defaultMandatoryWorkTimeStart!,
          defaultMandatoryWorkTimeEnd: user.defaultMandatoryWorkTimeEnd!,
          defaultBreakDuration: user.defaultBreakDuration!,
        );
}
