import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/dao_stream.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/streamable_dao.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/prisma.dart';

final _stream = DaoStream<WeekSetting?>(null);

class WeekSettingDao implements StreamableDao<WeekSetting?> {
  const WeekSettingDao();

  Future<void> loadUserSettings(int userId) async {
    final defaultSettings = await prisma.user.findUnique(
      where: UserWhereUniqueInput(id: userId),
    );
    if (defaultSettings == null) {
      throw 'Unknown User'; // TODO: centralize error handling
    }
    final weekDaySettings = await prisma.weekDaySetting.findMany(
      where: WeekDaySettingWhereInput(userId: PrismaUnion.$2(userId)),
    );
    _stream.emitReload(WeekSetting.fromPrismaModel(
      defaultSettings,
      weekDaySettings,
    ));
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
                          : null,
                      defaultWorkTimeEnd: setting.defaultWorkTimeEnd != null
                          ? PrismaUnion.$1(setting.defaultWorkTimeEnd!)
                          : null,
                      mandatoryWorkTimeStart:
                          setting.mandatoryWorkTimeStart != null
                              ? PrismaUnion.$1(setting.mandatoryWorkTimeStart!)
                              : null,
                      mandatoryWorkTimeEnd: setting.mandatoryWorkTimeEnd != null
                          ? PrismaUnion.$1(setting.mandatoryWorkTimeEnd!)
                          : null,
                      defaultBreakDuration: setting.defaultBreakDuration != null
                          ? PrismaUnion.$1(setting.defaultBreakDuration!)
                          : null,
                      timeEquivalent: setting.timeEquivalent,
                    ))));
      },
    );
    await loadUserSettings(userId);
  }

  @override
  WeekSetting? get data => _stream.state;
  @override
  Stream<WeekSetting?> get stream => _stream.stream;
}
