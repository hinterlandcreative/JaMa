
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jama/ui/models/time/time_category_model.dart';
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

  /// Gets a value indicating whether this month's report has been sent.
  bool get currentMonthReportSent => DateTime.now().month == _monthReportSent;

  /// Gets an observable stream of reports that have been sent.
  Stream<Tuple2<DateTime, DateTime>> get reportSent => _reportsSentStreamController.stream;

  void dispose() { 
    _reportsSentStreamController.close();
  }

  Future<ReportResult> getTimeReport({@required DateTime start, @required DateTime end}) async {
    assert(end != null);
    assert(start != null);
    assert(start.compareTo(end) >= 0);

    var time = await _timeService.getTimeEntriesByDate(startTime: start, endTime: end);
    var returnVisits = await _rvService.getVisitsByDate(start: start, end: end);
  }
}

class ReportResult {
  /// The total [hours]. [hours.item1] is a list of hours by `TimeCategory` and [hours.item2] is the goal. If goals are not being used [hours.item2] will be null.
  final Tuple2<List<TimeByCategory>, int> hours;
  /// The total [placements]. [placements.item1] is the value, [placements.item2] is the goal. If goals are not being used, [placements.item2] will be null.
  final Tuple2<int, int> placements;
  /// The total [videos]. [videos.item1] is the value, [videos.item2] is the goal. If goals are not being used, [videos.item2] will be null.
  final Tuple2<int, int> videos;
  /// The total [returnVisits]. [returnVisits.item1] is the value, [returnVisits.item2] is the goal. If goals are not being used, [returnVisits.item2] will be null.
  final Tuple2<int, int> returnVisits;
  /// The [startDate] of the report.
  final DateTime startDate;
  /// The [endDate] of the report.
  final DateTime endDate;
  /// The [entries] that make up this report organized by date of the entry.
  final Map<DateTime, ReportEntry> entries;

  ReportResult({this.hours, this.placements, this.videos, this.returnVisits, this.startDate, this.endDate, this.entries});
}


abstract class ReportEntry {
  /// The [hours] of this visit.
  final int hours;
  /// The total [placements].
  final int placements;
  /// The total [videos].
  final int videos;
  /// The [date].
  final DateTime date;

  const ReportEntry({this.hours, this.placements, this.videos, this.date});

  Future navigate(BuildContext context);
}

class _TimeReportEntry implements ReportEntry {
  @override
  final DateTime date;

  @override
  final int hours;

  @override
  final int placements;

  @override
  final int videos;

  const _TimeReportEntry({this.date, this.hours, this.placements, this.videos});

  @override
  Future navigate(BuildContext context) {
    // TODO: implement navigate
    throw UnimplementedError();
  }
}

class _ReturnVisitReportEntry implements ReportEntry {
  @override
  final DateTime date;

  @override
  final int hours = 0;

  @override
  final int placements;

  @override
  final int videos;

  const _ReturnVisitReportEntry({this.date, this.placements, this.videos});

  @override
  Future navigate(BuildContext context) {
    // TODO: implement navigate
    throw UnimplementedError();
  }
}