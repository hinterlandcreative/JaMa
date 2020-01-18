import 'package:flutter/material.dart';
import 'package:jama/ui/screens/home_screen.dart';

import 'ioc/dependency_registrar.dart';

void main() { 
  DependencyRegistrar.register();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JaMa Ministry',
      home: HomeScreen(),
    );
  }
}

