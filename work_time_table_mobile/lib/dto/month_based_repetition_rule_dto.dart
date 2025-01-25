class MonthBasedRepetitionRuleDto {
  final int repeatAfterMonths;
  final int dayIndex;
  final int? weekIndex;
  final bool countFromEnd;

  MonthBasedRepetitionRuleDto({
    required this.repeatAfterMonths,
    required this.dayIndex,
    required this.weekIndex,
    required this.countFromEnd,
  });

  factory MonthBasedRepetitionRuleDto.fromJson(Map<String, dynamic> json) =>
      MonthBasedRepetitionRuleDto(
        repeatAfterMonths: json['repeatAfterMonths'],
        dayIndex: json['dayIndex'],
        weekIndex: json['weekIndex'],
        countFromEnd: json['countFromEnd'],
      );

  Map<String, dynamic> toJson() => {
        'repeatAfterMonths': repeatAfterMonths,
        'dayIndex': dayIndex,
        'weekIndex': weekIndex,
        'countFromEnd': countFromEnd,
      };
}
