enum GlobalSettingKeyType {
  int,
  ;
}

enum GlobalSettingKey {
  scrollInterval(type: GlobalSettingKeyType.int),
  ;

  final GlobalSettingKeyType type;

  const GlobalSettingKey({required this.type});
}
