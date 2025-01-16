enum StatRange {
  AllTime(12345, "AllTime"),
  Day(1, "Day"),
  Week(7, "Week"),
  Month(30, "Month"),
  Year(365, "Year");

  const StatRange(this.days, this.label);

  final int days;
  final String label;

  @override
  toString() => label;
}
