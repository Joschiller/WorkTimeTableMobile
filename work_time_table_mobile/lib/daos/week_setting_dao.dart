import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/mapper/user_mapper.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/prisma.dart';

final _stream = ContextDependentStream<WeekSetting>();

class WeekSettingDao {
  const WeekSettingDao();

  Future<void> loadUserSettings(int? userId) async {
    if (userId == null) {
      _stream.emitReload(NoContextValue());
      return;
    }
    final user = await prisma.user.findUnique(
      where: UserWhereUniqueInput(id: userId),
    );
    if (user == null) {
      throw AppError.data_dao_unknownUser;
    }
    final weekDaySettings = await prisma.weekDaySetting.findMany(
      where: WeekDaySettingWhereInput(userId: PrismaUnion.$2(userId)),
    );
    _stream.emitReload(ContextValue(user.toWeekSetting(weekDaySettings)));
  }

  Future<void> updateByUserId(int userId, WeekSetting settings) async {
    await prisma.$transaction(
      (prisma) async {
        await prisma.user.update(
          data: PrismaUnion.$1(
            UserUpdateInput(
              targetWorkTimePerWeek:
                  PrismaUnion.$1(settings.targetWorkTimePerWeek),
            ),
          ),
          where: UserWhereUniqueInput(id: userId),
        );
        await prisma.weekDaySetting.deleteMany(
          where: WeekDaySettingWhereInput(userId: PrismaUnion.$2(userId)),
        );
        await prisma.weekDaySetting.createMany(
            data: PrismaUnion.$2(settings.weekDaySettings.values
                .map((setting) => WeekDaySettingCreateManyInput(
                      userId: userId,
                      day: setting.dayOfWeek.name,
                      timeEquivalent: setting.timeEquivalent,
                      mandatoryWorkTimeStart: setting.mandatoryWorkTimeStart,
                      mandatoryWorkTimeEnd: setting.mandatoryWorkTimeEnd,
                      defaultWorkTimeStart: setting.defaultWorkTimeStart,
                      defaultWorkTimeEnd: setting.defaultWorkTimeEnd,
                      defaultBreakDuration: setting.defaultBreakDuration,
                    ))));
      },
    );
    await loadUserSettings(userId);
  }

  ContextDependentStream<WeekSetting> get stream => _stream;
}
