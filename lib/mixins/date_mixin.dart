extension DateTimeMixins on DateTime {
  /// Create a new [DateTime] object without the time data.
  DateTime dropTime() => DateTime(this.year, this.month, this.day);

  /// Determines if two [DateTime] objects are on the same date.
  bool isSameDayAs(DateTime other) => this.dropTime() == other.dropTime();

  /// Creates a new [DateTime] with the date from [this] and the time from [other].
  DateTime replaceTimeFrom(DateTime other) => DateTime(this.year, this.month, this.day, other.hour, other.minute, other.millisecond, other.microsecond);

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

  String humanizeTimeSince() {
  
  /// The number of milliseconds that have passed since the timestamp
  int difference = DateTime.now().millisecondsSinceEpoch - this.millisecondsSinceEpoch;
  String result;

  if (difference < 60000) {
    result = countSeconds(difference);
  } else if (difference < 3600000) {
    result = countMinutes(difference);
  } else if (difference < 86400000) {
    result = countHours(difference);
  } else if (difference < 604800000) {
    result = countDays(difference);
  } else if (difference / 1000 < 2419200) {
    result = countWeeks(difference);
  } else if (difference / 1000 < 31536000) {
    result = countMonths(difference);
  } else
    result = countYears(difference);

  return !result.startsWith("J") ? result + ' ago' : result; 
}

/// Converts the time difference to a number of seconds.
/// This function truncates to the lowest second.
///   returns ("Just now" OR "X seconds")
String countSeconds(int difference) {
  int count = (difference / 1000).truncate();
  return count > 1 ? count.toString() + ' seconds' : 'Just now';
}

/// Converts the time difference to a number of minutes.
/// This function truncates to the lowest minute.
///   returns ("1 minute" OR "X minutes")
String countMinutes(int difference) {
  int count = (difference / 60000).truncate();
  return count.toString() + (count > 1 ? ' minutes' : ' minute');
}

/// Converts the time difference to a number of hours.
/// This function truncates to the lowest hour.
///   returns ("1 hour" OR "X hours")
String countHours(int difference) {
  int count = (difference / 3600000).truncate();
  return count.toString() + (count > 1 ? ' hours' : ' hour');
}

/// Converts the time difference to a number of days.
/// This function truncates to the lowest day.
///   returns ("1 day" OR "X days")
String countDays(int difference) {
  int count = (difference / 86400000).truncate();
  return count.toString() + (count > 1 ? ' days' : ' day');
}

/// Converts the time difference to a number of weeks.
/// This function truncates to the lowest week.
///   returns ("1 week" OR "X weeks" OR "1 month")
String countWeeks(int difference) {
  int count = (difference / 604800000).truncate();
  if (count > 3) {
    return '1 month';
  }
  return count.toString() + (count > 1 ? ' weeks' : ' week');
}

/// Converts the time difference to a number of months.
/// This function rounds to the nearest month.
///   returns ("1 month" OR "X months" OR "1 year")
String countMonths(int difference) {
  int count = (difference / 2628003000).round();
  count = count > 0 ? count : 1;
  if (count > 12) {
    return '1 year';
  }
  return count.toString() + (count > 1 ? ' months' : ' month');
}

/// Converts the time difference to a number of years.
/// This function truncates to the lowest year.
///   returns ("1 year" OR "X years")
String countYears(int difference) {
  int count = (difference / 31536000000).truncate();
  return count.toString() + (count > 1 ? ' years' : ' year');
  }
}

