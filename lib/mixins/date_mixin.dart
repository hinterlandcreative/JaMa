extension DateTimeMixins on DateTime {
  DateTime dropTime() => DateTime(this.year, this.month, this.day);
}