enum StatRange {
  AllTime(12345),
  Day(1),
  Week(7),
  Month(30),
  Year(365);

  const StatRange(this.days);

  final int days;
}
