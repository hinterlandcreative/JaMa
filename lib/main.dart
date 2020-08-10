import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart';
import 'package:jama/ui/screens/tabbed_controller_screen.dart';

import 'ioc/dependency_registrar.dart';

void main() {
  DependencyRegistrar.register();
  findSystemLocale().then((locale) {
    initializeDateFormatting(locale, null).then((_) => runApp(MyApp()));
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JaMa Ministry',
      home: TabbedController(),
    );
  }
}
