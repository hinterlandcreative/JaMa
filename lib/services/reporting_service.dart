import 'dart:async';

import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:jama/data/models/dto/visit_dto.dart';
import 'package:jama/ui/models/reporting/time_by_category.dart';
import 'package:kiwi/kiwi.dart';

import 'package:jama/services/app_settings_service.dart';
import 'package:jama/services/return_visit_service.dart';
import 'package:jama/services/time_service.dart';
import 'package:tuple/tuple.dart';
import 'package:jama/mixins/date_mixin.dart';
import 'package:jama/mixins/duration_mixin.dart';

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
        appSettingsService ?? KiwiContainer().resolve<AppSettingsService>(),
        returnVisitService ?? KiwiContainer().resolve<ReturnVisitService>(),
        timeService ?? KiwiContainer().resolve<TimeService>());
  }

  /// Sends the text message report to the stored default recipient for the given [year] and [month].
  /// If [includeDetails] is `true` then non-ministry time will be itemized by date.
  Future<bool> sendMonthlyReport(
      {@required BuildContext context,
      @required final int year,
      @required final int month,
      final bool transferPartialHoursToNextMonth = true}) async {
    var dateToReport = DateTime(year, month);
    var report = await getTimeReport(
        start: dateToReport.toFirstDayOfMonth(), end: dateToReport.toLastDayOfMonth());

    if (transferPartialHoursToNextMonth &&
        (report.totalDuration.inMinutes % 60 != 0 ||
            report.durationByCategories.item1.any((element) => element.time.inMinutes % 60 != 0))) {
      await confirmationDialog(
          context,
          "You currently have " +
              "${report.durationByCategories.item1.firstWhere((e) => e.category.isMinistry)?.timeString} " +
              "Ministry hours and ${report.totalDuration.toShortString()} total hours.\n\n " +
              "Do you want to forward the extra time to the next month?",
          title: "Forward time",
          positiveText: "Yes",
          positiveAction: () async {
            var failedCategories = await _timeService.forwardTime(report.startDate);
            if (failedCategories.isNotEmpty) {
              await infoDialog(
                  context,
                  "Could not update the following categories because they did not have enough time:\n" +
                      failedCategories.fold("", (p, e) => p + "${e.name}") +
                      "\n");
            }

            report = await getTimeReport(
                start: dateToReport.toFirstDayOfMonth(), end: dateToReport.toLastDayOfMonth());

            await sendExistingReport(report);

            return true;
          },
          negativeText: "No",
          negativeAction: () async {
            await sendExistingReport(report);
            return true;
          },
          showNeutralButton: false,
          confirm: false);
    }

    await sendExistingReport(report);

    return true;
  }

  Future sendExistingReport(ReportResult report) async {
    var includeDetails =
        await _appSettings.getSettingBool(AppSettingsService.include_details_in_report);
    Map<TimeCategory, String> details = {};
    for (var entry in report.timeEntries.entries) {
      entry.value.forEach((element) {
        if (!element.category.isMinistry) {
          details[element.category] = details[element.category] ??
              "" +
                  "${DateFormat.Md(Intl.systemLocale).format(element.date)}: ${element.duration.toShortString()}\n";
        }
      });
    }
    var includeSignature =
        await _appSettings.getSettingBool(AppSettingsService.include_signature_in_report);
    var signature = await _appSettings.getSettingString(AppSettingsService.signature);

    var totalHours = report.durationByCategories.item1
        .fold<Duration>(Duration.zero, (p, e) => p + e.time)
        .toShortString();

    var reportMessage =
        "${DateFormat.yMMMM(Intl.systemLocale).format(report.startDate)} Report\n---------\n\n" +
            "Hours: $totalHours\n" +
            (report.durationByCategories.item1.length == 1 &&
                    report.durationByCategories.item1.first.category.isMinistry
                ? ""
                : report.durationByCategories.item1.fold(
                    "",
                    (previousValue, element) =>
                        "$previousValue\n${element.category.name}:\n${element.timeString}\n")) +
            (report.placements.item1 > 0 ? "\nPlacements:    ${report.placements.item1}" : "") +
            (report.videos.item1 > 0 ? "\nVideos:        ${report.videos.item1}" : "") +
            (report.returnVisits.item1 > 0 ? "\nReturn Visits: ${report.returnVisits.item1}" : "") +
            (report.bibleStudies > 0 ? "\nBible Studies: ${report.bibleStudies}" : "") +
            (includeDetails
                ? "\n---------\n" +
                    details.entries.fold("", (p, entry) => "\n${entry.key.name}:\n" + entry.value)
                : "") +
            (includeSignature ? "\n\n$signature" : "");

    print(reportMessage);
    sendSMS(message: reportMessage, recipients: []);
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

    var time = await _timeService.getTimeEntriesByDate(start: start, end: end);
    var returnVisits = await _rvService.getAllReturnVisits(shallow: false);
    var useGoals = await _appSettings.getSettingBool(AppSettingsService.goals_enabled);

    Map<DateTime, List<Time>> timeEntries = {};

    for (var t in time) {
      if (timeEntries[t.date] == null) timeEntries[t.date] = <Time>[];
      timeEntries[t.date]..add(t);
    }

    return ReportResult(
        startDateInt: start.millisecondsSinceEpoch,
        endDateInt: end.millisecondsSinceEpoch,
        durationByCategories: Tuple2(
            time
                .map((e) => e.category)
                .toSet()
                .map((e) => DurationByCategory(
                    e,
                    Duration(
                        minutes: time.where((x) => x.category == e).fold(
                            0, (previousValue, element) => previousValue + element.totalMinutes))))
                .toList(),
            useGoals
                ? await _appSettings.getSettingInt(AppSettingsService.goals_monthly_hours)
                : null),
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
            useGoals
                ? await _appSettings.getSettingInt(AppSettingsService.goals_monthly_placements)
                : null),
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
            useGoals
                ? await _appSettings.getSettingInt(AppSettingsService.goals_monthly_videos)
                : null),
        returnVisits: Tuple2(
            returnVisits.where((rv) => rv.visits.length > 1).fold(0, (p, rv) => p + rv.visits.where((v) => v.date.isSameDayAs(start) || (v.date.isAfter(start) && v.date.isBefore(end)) || v.date.isSameDayAs(end)).length), null),
        bibleStudies: returnVisits.fold(0, (p, rv) => p + (rv.visits.any((visit) => visit.type == VisitType.Study && visit.date.isAfter(start) && visit.date.isBefore(end)) ? 1 : 0)),
        timeEntries: timeEntries,
        rvEntries: returnVisits);
  }
}

class ReportResult {
  static const ReportResult empty = ReportResult(
      durationByCategories: Tuple2<List<DurationByCategory>, int>([], null),
      placements: Tuple2<int, int>(0, null),
      videos: Tuple2<int, int>(0, null),
      returnVisits: Tuple2<int, int>(0, null),
      bibleStudies: 0,
      startDateInt: 0,
      endDateInt: 0);

  /// The total [durationByCategories]. [durationByCategories.item1] is a list of hours by `TimeCategory` and [durationByCategories.item2] is the goal. If goals are not being used [durationByCategories.item2] will be null.
  final Tuple2<List<DurationByCategory>, int> durationByCategories;

  /// The total [placements]. [placements.item1] is the value, [placements.item2] is the goal. If goals are not being used, [placements.item2] will be null.
  final Tuple2<int, int> placements;

  /// The total [videos]. [videos.item1] is the value, [videos.item2] is the goal. If goals are not being used, [videos.item2] will be null.
  final Tuple2<int, int> videos;

  /// The total [returnVisits]. [returnVisits.item1] is the value, [returnVisits.item2] is the goal. If goals are not being used, [returnVisits.item2] will be null.
  final Tuple2<int, int> returnVisits;

  /// The total number of [bibleStudies] conducted this period.
  final int bibleStudies;

  /// The [startDate] of the report as an int (fromMillisecondsSinceEpoch).
  final int startDateInt;

  /// The [endDate] of the report as an int (fromMillisecondsSinceEpoch).
  final int endDateInt;

  /// The [timeEntries] that make up this report organized by date of the entry.
  final Map<DateTime, List<Time>> timeEntries;

  /// The [rvEntries] that make up this report.
  final List<ReturnVisit> rvEntries;

  const ReportResult({
    this.durationByCategories,
    this.placements,
    this.videos,
    this.returnVisits,
    this.bibleStudies,
    this.startDateInt,
    this.endDateInt,
    this.timeEntries,
    this.rvEntries,
  });

  /// The [startDate] of the report as an int (fromMillisecondsSinceEpoch).
  DateTime get startDate => DateTime.fromMillisecondsSinceEpoch(startDateInt);

  /// The [endDate] of the report as an int (fromMillisecondsSinceEpoch).
  DateTime get endDate => DateTime.fromMillisecondsSinceEpoch(endDateInt);

  /// The total `Duration` from all categories.
  Duration get totalDuration =>
      durationByCategories.item1.fold(Duration.zero, (p, e) => p + e.time);

  /// Gets a value indicating if the report is for a single month.
  bool get isSingleMonth => startDate.month == endDate.month;
}
