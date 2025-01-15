enum StatRange {
  Day(1),
  Week(7),
  Month(30),
  Year(365),
  AllTime(12345);

  const StatRange(this.days);

  final int days;
}
