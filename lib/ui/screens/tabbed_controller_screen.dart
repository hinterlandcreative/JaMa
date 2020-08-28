import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:jama/ui/screens/reports/root_reports_screen.dart';
import 'package:jama/ui/screens/settings_screen.dart';
import 'package:jama/ui/screens/time/root_time_screen.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/screens/return_visits/root_return_visits_screen.dart';
import 'package:jama/ui/screens/home_screen.dart';

class TabbedController extends StatefulWidget {
  TabbedController({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TabbedControllerState createState() => _TabbedControllerState();
}

class _TabbedControllerState extends State<TabbedController> {
  int selectedIndex = 0;

  PageController controller = PageController(keepPage: true);

  List<GButton> tabs = new List();
  final List<Widget> _children = [
    HomeScreen(),
    RootTimeScreen(),
    RootReturnVisitsScreen(),
    RootReportsScreen(),
    SettingsScreen()
  ];

  @override
  void initState() {
    super.initState();

    var padding = EdgeInsets.symmetric(horizontal: 12, vertical: 5);
    double gap = 30;
    final iconInactiveColor = AppStyles.primaryColor;
    final iconColor = AppStyles.primaryColor;
    final textColor = AppStyles.primaryColor;
    final color = AppStyles.lightGrey;
    final double iconSize = 24;
    final textStyle = AppStyles.smallTextStyle
        .copyWith(color: AppStyles.primaryColor, fontWeight: FontWeight.bold);

    tabs.add(GButton(
      gap: gap,
      iconActiveColor: iconInactiveColor,
      iconColor: iconColor,
      textColor: textColor,
      textStyle: textStyle,
      backgroundColor: color,
      iconSize: iconSize,
      padding: padding,
      icon: LineIcons.home,
      text: 'Home',
    ));

    tabs.add(GButton(
      gap: gap,
      iconActiveColor: iconInactiveColor,
      iconColor: iconColor,
      textColor: textColor,
      textStyle: textStyle,
      backgroundColor: color,
      iconSize: iconSize,
      padding: padding,
      icon: LineIcons.clock_o,
      text: 'Time',
    ));

    tabs.add(GButton(
        gap: gap,
        iconActiveColor: iconInactiveColor,
        iconColor: iconColor,
        textColor: textColor,
        textStyle: textStyle,
        backgroundColor: color,
        iconSize: iconSize,
        padding: padding,
        icon: LineIcons.map_marker,
        text: "Return Visits"));

    tabs.add(GButton(
        gap: gap,
        iconActiveColor: iconInactiveColor,
        iconColor: iconColor,
        textColor: textColor,
        textStyle: textStyle,
        backgroundColor: color,
        iconSize: iconSize,
        padding: padding,
        icon: FeatherIcons.barChart2,
        text: "Reports"));

    tabs.add(GButton(
        gap: gap,
        iconActiveColor: iconInactiveColor,
        iconColor: iconColor,
        textColor: textColor,
        textStyle: textStyle,
        backgroundColor: color,
        iconSize: iconSize,
        padding: padding,
        icon: Icons.settings,
        text: "Settings"));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBody: true,
        body: PageView.builder(
          onPageChanged: (page) {
            setState(() {
              selectedIndex = page;
            });
          },
          controller: controller,
          itemBuilder: (context, position) {
            return Container(
              child: _children[position],
            );
          },
          itemCount: tabs.length, // Can be null
        ),
        // backgroundColor: Colors.green,
        // body: Container(color: Colors.red,),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: SafeArea(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: GNav(
                    gap: 4.0,
                    tabs: tabs,
                    selectedIndex: selectedIndex,
                    onTabChange: (index) {
                      print(index);
                      setState(() {
                        selectedIndex = index;
                      });
                      controller.jumpToPage(index);
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
