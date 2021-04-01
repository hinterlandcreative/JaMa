import '../../../mixins/duration_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:jama/services/app_settings_service.dart';
import 'package:jama/services/time_service.dart';
import 'package:kiwi/kiwi\.dart';

class SendCurrentReportModel extends ChangeNotifier {
  final TimeService _timeService;
  final AppSettingsService _appsettings;

  String _lastReportMonth = "";
  int _lastReportMonthInt;
  bool _dataLoaded = false;

  SendCurrentReportModel._(this._timeService, this._appsettings) {
    _loadData();
  }

  factory SendCurrentReportModel([TimeService timeService, AppSettingsService appSettings]) {
    var container = KiwiContainer();
    return SendCurrentReportModel._(timeService ?? container.resolve<TimeService>(),
        appSettings ?? container.resolve<AppSettingsService>());
  }

  String get lastReportString => _lastReportMonth.isEmpty ? "" : "Send $_lastReportMonth Report";

  Future sendReport() async {
    if (!_dataLoaded) return;

    var startDate = DateTime(DateTime.now().year, _lastReportMonthInt, 1);
    var endDate = DateTime(DateTime.now().year, _lastReportMonthInt + 1, 1)
        .subtract(Duration(milliseconds: 1));

    var timeEntries = await _timeService.getTimeEntriesByDate(start: startDate, end: endDate);

    Map<String, int> timeByCategory = {};
    List<TimeCategory> categories = timeEntries.map((f) => f.category).toSet().toList();

    for (var category in categories) {
      timeByCategory[category.name] = timeEntries
          .where((t) => t.category == category)
          .fold(0, (total, time) => total + time.totalMinutes);
    }

    var totalMinutes = timeByCategory.values.fold(0, (t, v) => t + v);

    String timeTotalString = timeByCategory.entries
        .map((t) => "${t.key}: ${Duration(minutes: t.value).toShortString()}")
        .toList()
        .fold<String>("", (s, n) => "$s\r\n$n");

    var placementsTotal = timeEntries.fold(0, (i, t) => i + t.placements);
    var videosTotal = timeEntries.fold(0, (i, t) => i + t.videos);

//     await sendSMS(message: """$_lastReportMonth Field Service Activity:

// Total Time: ${Duration(minutes: totalMinutes).toShortString()}
// $timeTotalString
// ${placementsTotal == 0 ? "" : "Placements: $placementsTotal"}
// ${videosTotal == 0 ? "" : "Videos: $videosTotal"}
// """, recipients: []);

    _appsettings.setSettingInt(AppSettingsService.last_report_sent, _lastReportMonthInt + 1);
    notifyListeners();
  }

  void _loadData() async {
    _dataLoaded = false;
    _lastReportMonthInt = await _appsettings.getSettingInt(
        AppSettingsService.last_report_sent, DateTime.now().month - 1);
    _lastReportMonth = DateFormat.MMMM(Intl.defaultLocale)
        .format(DateTime(DateTime.now().year, _lastReportMonthInt));
    notifyListeners();
    _dataLoaded = true;
  }
}
