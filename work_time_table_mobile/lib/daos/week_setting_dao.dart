import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/app_error.dart';
import 'package:work_time_table_mobile/daos/mapper/user_mapper.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/user_dependent_value.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/dao_stream.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/streamable_dao.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/prisma.dart';

final _stream = DaoStream<UserDependentValue<WeekSetting>>(NoUserValue());

class WeekSettingDao implements StreamableDao<UserDependentValue<WeekSetting>> {
  const WeekSettingDao();

  Future<void> loadUserSettings(int? userId) async {
    if (userId == null) {
      _stream.emitReload(NoUserValue());
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
    _stream.emitReload(UserValue(user.toWeekSetting(weekDaySettings)));
  }

  Future<void> updateByUserId(int userId, WeekSetting settings) async {
    await prisma.$transaction(
      (prisma) async {
        await prisma.user.update(
          data: PrismaUnion.$1(
            UserUpdateInput(
              targetWorkTimePerWeek:
                  PrismaUnion.$1(settings.targetWorkTimePerWeek),
              defaultWorkTimeStart: PrismaUnion.$1(
                  settings.globalWeekDaySetting.defaultWorkTimeStart),
              defaultWorkTimeEnd: PrismaUnion.$1(
                  settings.globalWeekDaySetting.defaultWorkTimeEnd),
              defaultMandatoryWorkTimeStart: PrismaUnion.$1(
                  settings.globalWeekDaySetting.defaultMandatoryWorkTimeStart),
              defaultMandatoryWorkTimeEnd: PrismaUnion.$1(
                  settings.globalWeekDaySetting.defaultMandatoryWorkTimeEnd),
              defaultBreakDuration: PrismaUnion.$1(
                  settings.globalWeekDaySetting.defaultBreakDuration),
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
                      defaultWorkTimeStart: setting.defaultWorkTimeStart != null
                          ? PrismaUnion.$1(setting.defaultWorkTimeStart!)
                          : const PrismaUnion.$2(PrismaNull()),
                      defaultWorkTimeEnd: setting.defaultWorkTimeEnd != null
                          ? PrismaUnion.$1(setting.defaultWorkTimeEnd!)
                          : const PrismaUnion.$2(PrismaNull()),
                      mandatoryWorkTimeStart:
                          setting.mandatoryWorkTimeStart != null
                              ? PrismaUnion.$1(setting.mandatoryWorkTimeStart!)
                              : const PrismaUnion.$2(PrismaNull()),
                      mandatoryWorkTimeEnd: setting.mandatoryWorkTimeEnd != null
                          ? PrismaUnion.$1(setting.mandatoryWorkTimeEnd!)
                          : const PrismaUnion.$2(PrismaNull()),
                      defaultBreakDuration: setting.defaultBreakDuration != null
                          ? PrismaUnion.$1(setting.defaultBreakDuration!)
                          : const PrismaUnion.$2(PrismaNull()),
                      timeEquivalent: setting.timeEquivalent,
                    ))));
      },
    );
    await loadUserSettings(userId);
  }

  @override
  UserDependentValue<WeekSetting> get data => _stream.state;
  @override
  Stream<UserDependentValue<WeekSetting>> get stream => _stream.stream;
}
