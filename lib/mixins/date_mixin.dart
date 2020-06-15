extension DateTimeMixins on DateTime {
  /// Create a new [DateTime] object without the time data.
  DateTime dropTime() => DateTime(this.year, this.month, this.day);

  /// Determines if two [DateTime] objects are on the same date.
  bool isSameDayAs(DateTime other) => this.dropTime() == other.dropTime();

  /// Finds the last day of the month for this DateTime. If [goToLastMillisecondOfLastDay] is true it will represent the latest possible time on the last day. 
  /// Otherwise the time portion of the DateTime will be 00:00:00:0000.
  DateTime toLastDayOfMonth([bool goToLastMillisecondOfLastDay = true]) => DateTime(this.year, this.month+1, 1).subtract(goToLastMillisecondOfLastDay ? Duration(milliseconds: 1) : Duration(days: 1));
  
  /// Finds the first day of this month and returns the earliest possible time.
  DateTime toFirstDayOfMonth() => DateTime(this.year, this.month, 1);

  DateTime toNearestIncrement({int increment = 15}) {
    if(increment > 60) {
      increment = 60;
    } else if(increment == 0) {
      return this;
    }
    return DateTime(this.year, this.month, this.day, this.hour, (this.minute / increment).round() * increment, this.second, this.millisecond, this.microsecond);
  }
}
