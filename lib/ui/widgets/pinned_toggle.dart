import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

import '../app_styles.dart';

class PinnedToggle extends StatelessWidget {
  final bool pinned;
  final Function(bool) onChanged;

  const PinnedToggle({Key key, this.pinned = false, @required this.onChanged,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ToggleSwitch(
      initialLabelIndex: !pinned ? 0 : 1,
      cornerRadius: 0,
      minWidth: 50,
      activeBgColor: AppStyles.primaryColor,
      activeTextColor: Colors.white,
      inactiveBgColor: Colors.grey.withAlpha(70),
      inactiveTextColor: Colors.white,
      labels: ['', ''],
      icons: [Typicons.pin_outline, Typicons.pin],
      activeColors: [Colors.redAccent[200], AppStyles.primaryColor],
      onToggle: (index) => onChanged(index == 1));
  }
}