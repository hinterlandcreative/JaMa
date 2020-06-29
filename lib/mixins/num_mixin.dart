extension NumMixin on num {
  int roundTo(int increment) {
    return (this / increment).round() * increment;
  }

  /// Convert an integer to a string containing commas every three digits.
  /// For example, 3000 becomes '3,000' and 45000 becomes '45,000'.
  String commaize() {
   // Convert int value to a String one
   String valueToString = '$this';

   // Use RegExp function witch used to match strings or parts of strings
   RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
   Function mathFunc = (Match match) => '${match[1]},';
   
   // Store the result in a new String value

   String newValue = valueToString.replaceAllMapped(reg, mathFunc);

   return '$newValue';
  }
}