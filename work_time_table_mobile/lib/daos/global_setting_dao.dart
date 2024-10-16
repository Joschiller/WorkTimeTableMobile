import 'package:orm/orm.dart';
import 'package:work_time_table_mobile/_generated_prisma_client/prisma.dart';
import 'package:work_time_table_mobile/models/global_setting_key.dart';
import 'package:work_time_table_mobile/models/settings_map.dart';
import 'package:work_time_table_mobile/prisma.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/dao_stream.dart';
import 'package:work_time_table_mobile/streamed_dao_helpers/streamable_dao.dart';

final initialGlobalSettingValue = SettingsMap();

final _stream = DaoStream<SettingsMap>(initialGlobalSettingValue);

class GlobalSettingDao implements StreamableDao<SettingsMap> {
  const GlobalSettingDao();

  Future<void> loadUserValues(int? userId) async {
    if (userId == null) {
      _stream.emitReload(initialGlobalSettingValue);
      return;
    }
    final settings = await prisma.globalSetting.findMany(
      where: GlobalSettingWhereInput(userId: PrismaUnion.$2(userId)),
    );
    _stream.emitReload(Map.fromIterable(settings.map((setting) => MapEntry(
          GlobalSettingKey.values.firstWhere((d) => d.name == setting.key),
          setting.value,
        ))));
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
  SettingsMap get data => _stream.state;
  @override
  Stream<SettingsMap> get stream => _stream.stream;
}
