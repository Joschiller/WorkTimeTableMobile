enum StatisticsMode {
  average(displayValue: 'Average'),
  median(displayValue: 'Median'),
  mode(displayValue: 'Mode'),
  ;

  const StatisticsMode({required this.displayValue});

  final String displayValue;
}
