extension NumMixin on num {
  int roundTo(int increment) {
    return (this / increment).round() * increment;
  }
}