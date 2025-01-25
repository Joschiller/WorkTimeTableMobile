class DayBasedRepetitionRuleDto {
  final int repeatAfterDays;

  DayBasedRepetitionRuleDto({required this.repeatAfterDays});

  factory DayBasedRepetitionRuleDto.fromJson(Map<String, dynamic> json) =>
      DayBasedRepetitionRuleDto(
        repeatAfterDays: json['repeatAfterDays'],
      );

  Map<String, dynamic> toJson() => {
        'repeatAfterDays': repeatAfterDays,
      };
}
