import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart';
import 'package:jama/ui/app_styles.dart';

import 'package:jama/ui/screens/tabbed_controller_screen.dart';
import 'package:jama/ioc/dependency_registrar.dart';

void main() {
  DependencyRegistrar.register();
  findSystemLocale().then((locale) {
    initializeDateFormatting(locale, null).then((_) => runApp(JamaMinistryApp()));
  });
}

class JamaMinistryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context).copyWith(
          primaryColor: AppStyles.primaryColor,
          backgroundColor: AppStyles.primaryBackground,
          accentColor: AppStyles.lightGrey,
          primaryTextTheme: TextTheme(bodyText1: AppStyles.paragraph)),
      debugShowCheckedModeBanner: false,
      title: 'JaMa Ministry',
      home: TabbedController(),
    );
  }
}
