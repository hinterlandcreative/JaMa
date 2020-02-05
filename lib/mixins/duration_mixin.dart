extension DurationMixin on Duration {
  String toShortString() {
    var minutes = this.inMinutes % 60;
    var hours = this.inHours;
    var timeString = "";
    if(hours > 0) {
      timeString = "${hours}h";
    } else if(minutes > 0) {
      timeString = "$timeString${minutes.toInt()}m";
    } else if (this.inMinutes <= 0) {
      return "0h";
    }

    return timeString;
  }
}
