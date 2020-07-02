
import 'dart:async';

import 'package:kiwi/kiwi.dart' as kiwi;

import 'package:jama/services/app_settings_service.dart';
import 'package:jama/services/return_visit_service.dart';
import 'package:jama/services/time_service.dart';
import 'package:tuple/tuple.dart';

class ReportingService {
  final AppSettingsService _appSettings;
  final ReturnVisitService _rvService;
  final TimeService _timeService;
  final StreamController<Tuple2<DateTime, DateTime>> _reportsSentStreamController = StreamController.broadcast();

  int _monthReportSent = 0;

  ReportingService._(this._appSettings, this._rvService, this._timeService) {
    _appSettings.getSettingInt(AppSettingsService.last_report_sent, _monthReportSent).then((value) => _monthReportSent = value);
  }

  factory ReportingService([AppSettingsService appSettingsService, ReturnVisitService returnVisitService, TimeService timeService]) {
    return ReportingService._(
      appSettingsService ?? kiwi.Container().resolve<AppSettingsService>(), 
      returnVisitService ?? kiwi.Container().resolve<ReturnVisitService>(), 
      timeService ?? kiwi.Container().resolve<TimeService>());
  }

  bool get currentMonthReportSent => DateTime.now().month == _monthReportSent;
}