import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:jama/ui/app_styles.dart';

class BaseScreen extends StatelessWidget {

  final Widget body;
  final Color _defaultTopBarColor = AppStyles.secondaryBackground;
  final Widget floatingActionButton;
  final Color topBarColor; 

  BaseScreen({Key key, @required this.body, this.topBarColor, this.floatingActionButton}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: Scaffold(
        backgroundColor: AppStyles.primaryBackground,
        floatingActionButton: floatingActionButton,
        body: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Container(
            color: topBarColor ?? _defaultTopBarColor,
            child: SafeArea(
              bottom: false,
              child: body),
          ),
        ),
      ),
    );
  }

}