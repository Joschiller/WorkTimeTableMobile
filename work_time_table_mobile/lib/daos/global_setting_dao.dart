import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/stream_helpers/context/streamable_context_dependent_dao.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_dao_stream.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';
import 'package:work_time_table_mobile/models/global_setting_key.dart';
import 'package:work_time_table_mobile/models/settings_map.dart';
import 'package:work_time_table_mobile/prisma.dart';

final _stream = ContextDependentDaoStream<SettingsMap>();

class GlobalSettingDao implements StreamableContextDependentDao<SettingsMap> {
  const GlobalSettingDao();

  Future<void> loadUserValues(int? userId) async {
    if (userId == null) {
      _stream.emitReload(NoContextValue());
      return;
    }
    final settings = await prisma.globalSetting.findMany(
      where: GlobalSettingWhereInput(userId: PrismaUnion.$2(userId)),
    );
    _stream.emitReload(
        ContextValue(Map.fromIterable(settings.map((setting) => MapEntry(
              GlobalSettingKey.values.firstWhere((d) => d.name == setting.key),
              setting.value,
            )))));
  }

  Future<void> updateByUserIdAndKey(
    int userId,
    GlobalSettingKey key,
    String? value,
  ) async {
    if (value == null) {
      await prisma.globalSetting.delete(
        where: GlobalSettingWhereUniqueInput(
            userIdKey: GlobalSettingUserIdKeyCompoundUniqueInput(
          userId: userId,
          key: key.name,
        )),
      );
      await loadUserValues(userId);
    } else {
      await prisma.globalSetting.upsert(
        where: GlobalSettingWhereUniqueInput(
            userIdKey: GlobalSettingUserIdKeyCompoundUniqueInput(
          userId: userId,
          key: key.name,
        )),
        create: PrismaUnion.$1(GlobalSettingCreateInput(
          key: key.name,
          value: value,
          user: UserCreateNestedOneWithoutGlobalSettingInput(
            connect: UserWhereUniqueInput(id: userId),
          ),
        )),
        update: PrismaUnion.$1(GlobalSettingUpdateInput(
          value: PrismaUnion.$1(value),
        )),
      );
      await loadUserValues(userId);
    }
  }

  @override
  ContextDependentValue<SettingsMap> get data => _stream.state;
  @override
  Stream<ContextDependentValue<SettingsMap>> get stream => _stream.stream;
}
