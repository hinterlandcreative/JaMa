extension DurationMixin on Duration {
  String toShortString() {
    var minutes = this.inMinutes % 60;
    var hours = this.inHours;
    var timeString = "";

    if (this.inMinutes <= 0) {
      return "0h";
    }

    if(hours > 0) {
      timeString = "${hours}h";
    }
    
    if(minutes > 0) {
      timeString = "$timeString${minutes.toInt()}m";
    } 
    return timeString;
  }
}
