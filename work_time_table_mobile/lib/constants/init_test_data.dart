import 'package:work_time_table_mobile/daos/day_value_dao.dart';
import 'package:work_time_table_mobile/daos/event_setting_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/daos/week_setting_dao.dart';
import 'package:work_time_table_mobile/daos/week_value_dao.dart';
import 'package:work_time_table_mobile/models/event_setting/day_based_repetition_rule.dart';
import 'package:work_time_table_mobile/models/event_setting/event_setting.dart';
import 'package:work_time_table_mobile/models/event_setting/event_type.dart';
import 'package:work_time_table_mobile/models/event_setting/month_based_repetition_rule.dart';
import 'package:work_time_table_mobile/models/value/day_mode.dart';
import 'package:work_time_table_mobile/models/value/day_value.dart';
import 'package:work_time_table_mobile/models/value/week_value.dart';
import 'package:work_time_table_mobile/models/week_setting/day_of_week.dart';
import 'package:work_time_table_mobile/models/week_setting/week_day_setting.dart';
import 'package:work_time_table_mobile/models/week_setting/week_setting.dart';
import 'package:work_time_table_mobile/prisma.dart';

Future<void> initTestData() async {
  // delete all data
  await prisma.user.deleteMany();

  // create test data
  await const UserDao().createFirstUser('Otto Normalverbraucher');
  final initialUserId = (await prisma.user.findFirst())?.id;
  if (initialUserId != null) {
    await const WeekSettingDao().updateByUserId(
      initialUserId,
      WeekSetting(
        targetWorkTimePerWeek: 17 * 60,
        weekDaySettings: {
          for (final dayOfWeek in [
            DayOfWeek.monday,
            DayOfWeek.tuesday,
            DayOfWeek.wednesday,
            DayOfWeek.thursday,
            DayOfWeek.friday,
          ])
            dayOfWeek: WeekDaySetting(
              dayOfWeek: dayOfWeek,
              timeEquivalent: 4 * 60,
              mandatoryWorkTimeStart: 11 * 60,
              mandatoryWorkTimeEnd: 12 * 60,
              defaultWorkTimeStart: 8 * 60,
              defaultWorkTimeEnd: 12 * 60,
              defaultBreakDuration: 30,
            ),
        },
      ),
    );
    await const EventSettingDao().create(
      initialUserId,
      EventSetting(
        id: -1,
        eventType: EventType.publicHoliday,
        title: 'Christmas',
        startDate: DateTime.utc(2024, 12, 24),
        endDate: DateTime.utc(2024, 12, 26),
        startIsHalfDay: true,
        endIsHalfDay: false,
        dayBasedRepetitionRules: [],
        monthBasedRepetitionRules: [
          MonthBasedRepetitionRule(
            repeatAfterMonths: 12,
            monthBasedRepetitionRuleBase: MonthBasedRepetitionRuleBase(
              dayIndex: 23,
              weekIndex: null,
              countFromEnd: false,
            ),
          ),
        ],
      ),
    );
    await const EventSettingDao().create(
      initialUserId,
      EventSetting(
        id: -1,
        eventType: EventType.vacation,
        title: 'Vacation',
        startDate: DateTime.utc(2024, 12, 27),
        endDate: DateTime.utc(2024, 12, 27),
        startIsHalfDay: false,
        endIsHalfDay: false,
        dayBasedRepetitionRules: [],
        monthBasedRepetitionRules: [],
      ),
    );
    await const EventSettingDao().create(
      initialUserId,
      EventSetting(
        id: -1,
        eventType: EventType.businessTrip,
        title: 'Weekly Trip',
        startDate: DateTime.utc(2025, 1, 2),
        endDate: DateTime.utc(2025, 1, 3),
        startIsHalfDay: false,
        endIsHalfDay: true,
        dayBasedRepetitionRules: [
          DayBasedRepetitionRule(repeatAfterDays: 7),
        ],
        monthBasedRepetitionRules: [],
      ),
    );
    for (var d = DateTime.utc(2024, 12, 16);
        d.isBefore(DateTime.utc(2024, 12, 21));
        d = d.add(const Duration(days: 1))) {
      await const DayValueDao().upsert(
        initialUserId,
        DayValue(
          date: d,
          firstHalfMode: DayMode.workDay,
          secondHalfMode: DayMode.workDay,
          workTimeStart: 8 * 60,
          workTimeEnd: 12 * 60,
          breakDuration: 30,
        ),
      );
    }
    for (var d = DateTime.utc(2024, 12, 21);
        d.isBefore(DateTime.utc(2024, 12, 23));
        d = d.add(const Duration(days: 1))) {
      await const DayValueDao().upsert(
        initialUserId,
        DayValue(
          date: d,
          firstHalfMode: DayMode.nonWorkDay,
          secondHalfMode: DayMode.nonWorkDay,
          workTimeStart: 0,
          workTimeEnd: 0,
          breakDuration: 0,
        ),
      );
    }
    const WeekValueDao().create(
      initialUserId,
      WeekValue(
        weekStartDate: DateTime.utc(2024, 12, 16),
        targetTime: 17 * 60,
      ),
    );
  }
}
