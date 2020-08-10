import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart';
import 'package:jama/data/core/db/database_provider2.dart';
import 'package:jama/services/database_service2.dart';
import 'package:jama/services/time_service.dart';
import 'package:jama/ui/screens/tabbed_controller_screen.dart';
import 'package:provider/provider.dart';

import 'ioc/dependency_registrar.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'JaMa Ministry',
      home: TabbedController(),
    );
  }
}
