import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jama/data/models/dto/visit_dto.dart';
import 'package:jama/ui/models/reporting/time_by_category.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'package:jama/services/app_settings_service.dart';
import 'package:jama/services/return_visit_service.dart';
import 'package:jama/services/time_service.dart';
import 'package:tuple/tuple.dart';

class ReportingService {
  final AppSettingsService _appSettings;
  final ReturnVisitService _rvService;
  final TimeService _timeService;
  final StreamController<Tuple2<DateTime, DateTime>> _reportsSentStreamController =
      StreamController.broadcast();

  int _monthReportSent = 0;

  ReportingService._(this._appSettings, this._rvService, this._timeService) {
    _appSettings
        .getSettingInt(AppSettingsService.last_report_sent, _monthReportSent)
        .then((value) => _monthReportSent = value);
  }

  factory ReportingService(
      [AppSettingsService appSettingsService,
      ReturnVisitService returnVisitService,
      TimeService timeService]) {
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
    assert(start.compareTo(end) <= 0);

    var time = await _timeService.getTimeEntriesByDate(startTime: start, endTime: end);
    var returnVisits = await _rvService.getAllReturnVisits(shallow: false);

    Map<DateTime, List<Time>> timeEntries = {};

    for (var t in time) {
      if (timeEntries[t.date] == null) timeEntries[t.date] = <Time>[];
      timeEntries[t.date]..add(t);
    }

    return ReportResult(
        startDateInt: start.millisecondsSinceEpoch,
        endDateInt: end.millisecondsSinceEpoch,
        hours: Tuple2(
            time
                .map((e) => e.category)
                .toSet()
                .map((e) => DurationByCategory(
                    e,
                    Duration(
                        minutes: time.where((x) => x.category == e).fold(
                            0, (previousValue, element) => previousValue + element.totalMinutes))))
                .toList(),
            null // TODO: goals needed here.
            ),
        placements: Tuple2(
            time.fold(0, (previousValue, element) => previousValue + element.placements) +
                returnVisits.fold(
                    0,
                    (p1, rv) =>
                        p1 +
                        rv.visits.fold(
                            0,
                            (p2, v) =>
                                p2 +
                                v.placements
                                    .where((p) => p.type != PlacementType.Video)
                                    .fold(0, (p3, p) => p3 + p.count))),
            null // TODO: goals needed here
            ),
        videos: Tuple2(
            time.fold(0, (previousValue, element) => previousValue + element.videos) +
                returnVisits.fold(
                    0,
                    (p1, rv) =>
                        p1 +
                        rv.visits.fold(
                            0,
                            (p2, v) =>
                                p2 +
                                v.placements
                                    .where((p) => p.type == PlacementType.Video)
                                    .fold(0, (p3, p) => p3 + p.count))),
            null // TODO: goals needed here
            ),
        returnVisits: Tuple2(returnVisits.length, null),
        timeEntries: timeEntries,
        rvEntries: returnVisits);
  }
}

class ReportResult {
  static const ReportResult empty = ReportResult(
      hours: Tuple2<List<DurationByCategory>, int>([], null),
      placements: Tuple2<int, int>(0, null),
      videos: Tuple2<int, int>(0, null),
      returnVisits: Tuple2<int, int>(0, null),
      startDateInt: 0,
      endDateInt: 0);

  /// The total [hours]. [hours.item1] is a list of hours by `TimeCategory` and [hours.item2] is the goal. If goals are not being used [hours.item2] will be null.
  final Tuple2<List<DurationByCategory>, int> hours;

  /// The total [placements]. [placements.item1] is the value, [placements.item2] is the goal. If goals are not being used, [placements.item2] will be null.
  final Tuple2<int, int> placements;

  /// The total [videos]. [videos.item1] is the value, [videos.item2] is the goal. If goals are not being used, [videos.item2] will be null.
  final Tuple2<int, int> videos;

  /// The total [returnVisits]. [returnVisits.item1] is the value, [returnVisits.item2] is the goal. If goals are not being used, [returnVisits.item2] will be null.
  final Tuple2<int, int> returnVisits;

  /// The [startDate] of the report as an int (fromMillisecondsSinceEpoch).
  final int startDateInt;

  /// The [endDate] of the report as an int (fromMillisecondsSinceEpoch).
  final int endDateInt;

  /// The [timeEntries] that make up this report organized by date of the entry.
  final Map<DateTime, List<Time>> timeEntries;

  /// The [rvEntries] that make up this report.
  final List<ReturnVisit> rvEntries;

  const ReportResult({
    this.hours,
    this.placements,
    this.videos,
    this.returnVisits,
    this.startDateInt,
    this.endDateInt,
    this.timeEntries,
    this.rvEntries,
  });

  /// The [startDate] of the report as an int (fromMillisecondsSinceEpoch).
  DateTime get startDate => DateTime.fromMillisecondsSinceEpoch(startDateInt);

  /// The [endDate] of the report as an int (fromMillisecondsSinceEpoch).
  DateTime get endDate => DateTime.fromMillisecondsSinceEpoch(endDateInt);
}
