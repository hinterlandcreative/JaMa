import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:jama/services/app_settings_service.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/widgets/spacer.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController monthlyGoals = TextEditingController();
  TextEditingController monthlyPlacements = TextEditingController();
  TextEditingController monthlyVideos = TextEditingController();

  AppSettingsService settingsService;

  @override
  void initState() {
    getSettingsValues();
    super.initState();
  }

  Future getSettingsValues() async {
    settingsService = kiwi.Container().resolve<AppSettingsService>();
    monthlyGoals.text =
        (await settingsService.getSettingInt(AppSettingsService.goals_monthly_hours, 0)).toString();
    monthlyPlacements.text =
        (await settingsService.getSettingInt(AppSettingsService.goals_monthly_placements, 0))
            .toString();
    monthlyVideos.text =
        (await settingsService.getSettingInt(AppSettingsService.goals_monthly_videos, 0))
            .toString();
  }

  @override
  void dispose() {
    monthlyGoals.dispose();
    monthlyPlacements.dispose();
    monthlyVideos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppStyles.primaryColor,
          centerTitle: false,
          title: Text("Settings", style: AppStyles.heading1),
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppStyles.leftMargin),
          child: ChangeNotifierProvider(
            create: (context) => _AppSettingsModel(),
            child: Consumer<_AppSettingsModel>(
              builder: (context, model, _) => Column(
                children: [
                  VerticalSpace(30.0),
                  Text("This settings page is not final and is just here for testing purposes."),
                  VerticalSpace(30.0),
                  Text("GOALS", style: AppStyles.heading3),
                  VerticalSpace(15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 7,
                        child: Text("Do you wan to use goals?"),
                      ),
                      Flexible(
                          flex: 3,
                          child: Switch(
                            value: model.goalsEnabled,
                            onChanged: (value) => model.goalsEnabled = value,
                          ))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 7,
                        child: Text("Monthly Hours"),
                      ),
                      Flexible(
                        flex: 3,
                        child: TextField(
                          controller: monthlyGoals,
                          onChanged: (value) => model.monthlyHours = int.parse(value),
                          keyboardType: TextInputType.number,
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 7,
                        child: Text("Monthly Placements"),
                      ),
                      Flexible(
                        flex: 3,
                        child: TextField(
                          controller: monthlyPlacements,
                          onChanged: (value) => model.monthlyPlacements = int.parse(value),
                          keyboardType: TextInputType.number,
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 7,
                        child: Text("Monthly Videos"),
                      ),
                      Flexible(
                        flex: 3,
                        child: TextField(
                          controller: monthlyVideos,
                          onChanged: (value) => model.monthlyVideos = int.parse(value),
                          keyboardType: TextInputType.number,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppSettingsModel extends ChangeNotifier {
  int _monthlyHours = 0;
  int _monthlyPlacements = 0;
  int _monthlyVideos = 0;
  bool _goalsEnabled = false;
  String _signature = "";
  bool _includeDetailsInReport = false;

  final AppSettingsService settingsService;

  _AppSettingsModel._(this.settingsService) {
    _loadData();
  }

  factory _AppSettingsModel([AppSettingsService appSettingsService]) {
    return _AppSettingsModel._(
        appSettingsService ?? kiwi.Container().resolve<AppSettingsService>());
  }

  int get monthlyHours => _monthlyHours;
  int get monthlyPlacements => _monthlyPlacements;
  int get monthlyVideos => _monthlyVideos;
  bool get goalsEnabled => _goalsEnabled;
  String get signature => _signature;
  bool get includeDetailsInReport => _includeDetailsInReport;

  set monthlyHours(int value) {
    value = value;
    if (_monthlyHours != value) {
      _monthlyHours = value;
      settingsService.setSettingInt(AppSettingsService.goals_monthly_hours, value);
      notifyListeners();
    }
  }

  set monthlyPlacements(int value) {
    if (_monthlyPlacements != value) {
      _monthlyPlacements = value;
      settingsService.setSettingInt(AppSettingsService.goals_monthly_placements, value);
      notifyListeners();
    }
  }

  set monthlyVideos(int value) {
    if (_monthlyVideos != value) {
      _monthlyVideos = value;
      settingsService.setSettingInt(AppSettingsService.goals_monthly_videos, value);
      notifyListeners();
    }
  }

  set goalsEnabled(bool value) {
    if (_goalsEnabled != value) {
      _goalsEnabled = value;
      settingsService.setSettingBool(AppSettingsService.goals_enabled, value);
      notifyListeners();
    }
  }

  set includeDetailsInReport(bool value) {
    if (_includeDetailsInReport != value) {
      _includeDetailsInReport = value;
      settingsService.setSettingBool(AppSettingsService.include_signature_in_report, value);
      notifyListeners();
    }
  }

  set signature(String value) {
    if (_signature != value) {
      _signature = value;
      settingsService.setSettingString(AppSettingsService.signature, value);
      notifyListeners();
    }
  }

  Future _loadData() async {
    _monthlyHours = await settingsService.getSettingInt(AppSettingsService.goals_monthly_hours);
    _monthlyPlacements =
        await settingsService.getSettingInt(AppSettingsService.goals_monthly_placements);
    _monthlyVideos = await settingsService.getSettingInt(AppSettingsService.goals_monthly_videos);
    _goalsEnabled = await settingsService.getSettingBool(AppSettingsService.goals_enabled);
    _includeDetailsInReport =
        await settingsService.getSettingBool(AppSettingsService.include_signature_in_report);
    _signature = await settingsService.getSettingString(AppSettingsService.signature);
    notifyListeners();
  }
}
