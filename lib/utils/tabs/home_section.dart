enum HomeSection {
  CalendarView('Calendar View'),
  Top('Top 10 Near Deadline');

  final String customName;

  const HomeSection(this.customName);

  @override
  toString() => customName;
}
