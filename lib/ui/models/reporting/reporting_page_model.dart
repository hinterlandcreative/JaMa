import 'dart:async';

import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:jama/data/models/dto/visit_dto.dart';
import 'package:jama/services/location_service.dart';
import 'package:jama/services/time_service.dart';
import 'package:kiwi/kiwi\.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:tuple/tuple.dart';

import 'package:jama/ui/models/navigatable.dart';
import 'package:jama/services/reporting_service.dart';
import 'package:jama/ui/models/reporting/time_by_category.dart';
import 'package:jama/mixins/duration_mixin.dart';
import 'package:jama/mixins/date_mixin.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/models/return_visits/return_visit_list_item_model.dart';
import 'package:jama/ui/screens/generic_collection_screen.dart';
import 'package:jama/ui/widgets/return_visit_card_widget.dart';

class ReportingPageModel extends ChangeNotifier {
  final Map<ReportingMode, String> _reportingModeToUIString = {
    ReportingMode.CurrentMonth:
        "${DateFormat.MMMMd(Intl.systemLocale).format(DateTime.now().toFirstDayOfMonth())} - ${DateFormat.MMMMd(Intl.systemLocale).format(DateTime.now().toLastDayOfMonth())}",
    ReportingMode.LastMonth: "Last Month",
    ReportingMode.ServiceYear: "Service Year",
    ReportingMode.Custom: "Custom"
  };
  final ReportingService _reportingService;
  final LocationService _locationService;
  final TimeService _timeService;

  String _name = "Trevor";
  ReportResult _results = ReportResult.empty;
  ReportingMode _mode = ReportingMode.CurrentMonth;
  List<ReturnVisitSummaryItem> _rvSummaryItems = [];
  bool _isLoading = true;
  Tuple2<List<charts.Series<dynamic, dynamic>>, String> _placementsSeries = Tuple2([], "");
  Tuple2<List<charts.Series<dynamic, dynamic>>, String> _videosSeries = Tuple2([], "");
  List<double> _timeByDayChartData = [0, 0, 0, 0, 0, 0, 0];
  StreamSubscription<Time> _timeServiceSubscription;
  DateTime _start, _end;
  bool _ignoreUpdates = false;

  ReportingPageModel._(this._mode, this._reportingService, this._locationService, this._timeService,
      [DateTime start, DateTime end]) {
    _start = start;
    _end = end;
    _timeServiceSubscription = _timeService.timeUpdatedStream.listen((event) {
      if (!_ignoreUpdates) {
        _loadData(_start, _end);
      }
    });
    _loadData(_start, _end);
  }

  factory ReportingPageModel.currentMonth(
      [ReportingService reportingService,
      LocationService locationService,
      TimeService timeService]) {
    return ReportingPageModel._(
        ReportingMode.CurrentMonth,
        reportingService ?? KiwiContainer().resolve<ReportingService>(),
        locationService ?? KiwiContainer().resolve<LocationService>(),
        timeService ?? KiwiContainer().resolve<TimeService>());
  }

  factory ReportingPageModel.lastMonth(
      [ReportingService reportingService,
      LocationService locationService,
      TimeService timeService]) {
    return ReportingPageModel._(
        ReportingMode.LastMonth,
        reportingService ?? KiwiContainer().resolve<ReportingService>(),
        locationService ?? KiwiContainer().resolve<LocationService>(),
        timeService ?? KiwiContainer().resolve<TimeService>());
  }

  factory ReportingPageModel.serviceYear(
      [ReportingService reportingService,
      LocationService locationService,
      TimeService timeService]) {
    return ReportingPageModel._(
        ReportingMode.ServiceYear,
        reportingService ?? KiwiContainer().resolve<ReportingService>(),
        locationService ?? KiwiContainer().resolve<LocationService>(),
        timeService ?? KiwiContainer().resolve<TimeService>());
  }

  factory ReportingPageModel.custom(DateTime start, DateTime end,
      [ReportingService reportingService,
      LocationService locationService,
      TimeService timeService]) {
    return ReportingPageModel._(
        ReportingMode.CurrentMonth,
        reportingService ?? KiwiContainer().resolve<ReportingService>(),
        locationService ?? KiwiContainer().resolve<LocationService>(),
        timeService ?? KiwiContainer().resolve<TimeService>(),
        start,
        end);
  }

  /// Gets a list of the strings for `ReportingMode`
  List<Tuple2<ReportingMode, String>> get availableReportingModes =>
      _reportingModeToUIString.entries
          .map((e) => Tuple2<ReportingMode, String>(e.key, e.value))
          .toList();

  /// Gets the current `ReportingMode` as a `String`.
  String get currentReportingModeString => _reportingModeToUIString[_mode];

  /// Gets the current `ReportingMode`
  ReportingMode get currentReportingMode => _mode;

  set currentReportingMode(ReportingMode value) {
    if (_mode != value) {
      _mode = value;
      _loadData(null, null);
    }
  }

  bool get hasReport =>
      _results.durationByCategories.item1.length > 0 || _results.returnVisits.item1 > 0;

  /// Gets a value indicating the [startDate].
  DateTime get startDate => _results.startDate;

  /// Gets a value indicating the [endDate].
  DateTime get endDate => _results.endDate;

  /// Gets a value indicating the total time the user has for the period.
  String get timeTotal => _results.durationByCategories.item1
      .fold<Duration>(Duration.zero, (p, e) => p + e.time)
      .toShortString();

  /// Gets a value indicating whether the user has time goals enabled.
  bool get timeHasGoal => _results.durationByCategories.item2 != null;

  /// Gets a value indicating the user's time goal.
  String get timeGoal => timeHasGoal
      ? Duration(hours: _results.durationByCategories.item2).toShortString()
      : Duration.zero.toShortString();

  /// Gets the entry message.
  String get entryMessage => "Great work $_name! Here’s how your ministry is looking.";

  /// Gets the time for each `TimeCategory`.
  List<DurationByCategory> get timeGoalsByCategory => _results.durationByCategories.item1;

  /// Gets a value indicating whether the user has placements goals enabled.
  bool get placementsHasGoal => _results.placements.item2 != null;

  /// Gets a value indicating whether the user has placements for this period.
  bool get placementsHasValue => _results.placements.item1 > 0;

  /// Gets the chart series data for placements.
  Tuple2<List<charts.Series<dynamic, dynamic>>, String> get placementsSeries => _placementsSeries;

  /// Gets a value indicating whether the user has videos goals enabled.
  bool get videosHasGoal => _results.videos.item2 != null;

  /// Gets a value indicating whether the user has videos for this period.
  bool get videosHasValue => _results.videos.item1 > 0;

  /// Gets the chart seris data for videos.
  Tuple2<List<charts.Series<dynamic, dynamic>>, String> get videosSeries => _videosSeries;

  /// Gets the summary items for `ReturnVisit`s.
  List<ReturnVisitSummaryItem> get rvSummaryItems => _rvSummaryItems;

  List<double> get timeByDayChartData => _timeByDayChartData;

  /// Gets a value indicating if the report is loading.
  bool get isLoading => _isLoading;

  /// Gets the list of [timeEntries] mapped by date.
  Map<DateTime, List<Time>> get timeEntries => _results.timeEntries;

  @override
  void dispose() {
    _timeServiceSubscription.cancel();
    super.dispose();
  }

  Future _loadData(DateTime start, DateTime end) async {
    if (start == null && end == null && _mode == ReportingMode.Custom) {
      throw ArgumentError.notNull("Start and End can't be null if `ReportingMode` is Custom");
    }

    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    var now = DateTime.now();

    switch (_mode) {
      case ReportingMode.CurrentMonth:
        _start = DateTime.now().toFirstDayOfMonth();
        _end = DateTime.now().toLastDayOfMonth();
        break;
      case ReportingMode.LastMonth:
        _start = DateTime(now.year, now.month - 1, 1);
        _end = _start.toLastDayOfMonth();
        break;
      case ReportingMode.ServiceYear:
        if (now.month >= 9) {
          _start = DateTime(now.year, 9, 1);
          _end = DateTime(now.year + 1, 8).toLastDayOfMonth();
        } else {
          _start = DateTime(now.year - 1, 9, 1);
          _end = DateTime(now.year, 8).toLastDayOfMonth();
        }
        break;
      case ReportingMode.Custom:
        _start = start;
        _end = end;
        break;
    }

    _results = await _reportingService.getTimeReport(start: _start, end: _end);

    await _buildReturnVisitSummaries(_start, _end);

    _buildPlacementsChartData();

    _buildTimeByDayChartData();

    _isLoading = false;
    notifyListeners();
  }

  Future _buildReturnVisitSummaries(DateTime start, DateTime end) async {
    var position = await _locationService.getCurrentOrLastKnownPosition();
    var padding = EdgeInsets.symmetric(horizontal: AppStyles.leftMargin, vertical: 30.0);

    var visitsMadeDuringPeriod = _results.rvEntries
        .where((rv) =>
            rv.visits.any((v) => v.date.compareTo(start) >= 0 && v.date.compareTo(end) <= 0))
        .toList();
    var visitsMadeSummary = ReturnVisitSummaryItem(
        count: visitsMadeDuringPeriod.length,
        summary: "visits made",
        iconPath: "graphics/check-circle.png",
        onNavigate: (context) async {
          if (visitsMadeDuringPeriod.isNotEmpty) {
            await showBarModalBottomSheet(
                context: context,
                builder: (_) => GenericCollectionScreen(
                      title: "Visits Made $currentReportingModeString",
                      itemPadding: padding,
                      items: visitsMadeDuringPeriod,
                      itemBuilder: (rv) => ReturnVisitCard(
                        returnVisit: ReturnVisitListItemModel(
                            returnVisit: rv,
                            currentLatitude: position.latitude,
                            currentLongitude: position.longitude),
                      ),
                    ));
          }
        });

    var newVisitsThisPeriod = _results.rvEntries.where((rv) {
      var initialVisit = rv.visits.minBy((a, b) => a.date.compareTo(b.date));
      return initialVisit.date.compareTo(start) >= 0 && initialVisit.date.compareTo(end) <= 0;
    }).toList();
    var newVisitsSummary = ReturnVisitSummaryItem(
        count: newVisitsThisPeriod.length,
        summary: "new return visits",
        iconPath: "graphics/message-square.png",
        onNavigate: (context) async {
          if (newVisitsThisPeriod.isNotEmpty) {
            await showBarModalBottomSheet(
                context: context,
                builder: (_) => GenericCollectionScreen(
                      title: "New Return Visits $currentReportingModeString",
                      itemPadding: padding,
                      items: newVisitsThisPeriod,
                      itemBuilder: (rv) => ReturnVisitCard(
                        returnVisit: ReturnVisitListItemModel(
                            returnVisit: rv,
                            currentLatitude: position.latitude,
                            currentLongitude: position.longitude),
                      ),
                    ));
          }
        });

    var noVisitsDuringPeriod = _results.rvEntries
        .where((element) => visitsMadeDuringPeriod.contains(element) == false)
        .toList();
    var noVisitsSummary = ReturnVisitSummaryItem(
        summary: "no vists",
        count: noVisitsDuringPeriod.length,
        iconPath: "graphics/notification.png",
        onNavigate: (context) async {
          if (noVisitsDuringPeriod.isNotEmpty) {
            await showBarModalBottomSheet(
                context: context,
                builder: (_) => GenericCollectionScreen(
                      title: "No Visits $currentReportingModeString",
                      itemPadding: padding,
                      items: noVisitsDuringPeriod,
                      itemBuilder: (rv) => ReturnVisitCard(
                        returnVisit: ReturnVisitListItemModel(
                            returnVisit: rv,
                            currentLatitude: position.latitude,
                            currentLongitude: position.longitude),
                      ),
                    ));
          }
        });

    _rvSummaryItems = [visitsMadeSummary, newVisitsSummary, noVisitsSummary];

    var bibleStudies = _results.rvEntries.where((rv) => rv.visits.any((visit) =>
        visit.type == VisitType.Study && visit.date.isAfter(start) && visit.date.isBefore(end)));

    if (bibleStudies.isNotEmpty) {
      _rvSummaryItems.add(ReturnVisitSummaryItem(
          summary: "bible studies",
          count: bibleStudies.length,
          icon: Icons.library_books,
          onNavigate: (context) => showBarModalBottomSheet(
              context: context,
              builder: (_) => GenericCollectionScreen(
                    title: "Bible Studies",
                    itemPadding: padding,
                    items: bibleStudies,
                    itemBuilder: (rv) => ReturnVisitCard(
                      returnVisit: ReturnVisitListItemModel(
                          returnVisit: rv,
                          currentLatitude: position.latitude,
                          currentLongitude: position.longitude),
                    ),
                  ))));
    }
  }

  void _buildPlacementsChartData() {
    List<Tuple3<int, int, Color>> placementsData = [];
    placementsData.add(Tuple3(1, _results.placements.item1, AppStyles.primaryColor));
    if (placementsHasGoal) {
      placementsData.add(Tuple3(2, _results.placements.item2, AppStyles.chartsUnusedColor));
    }

    _placementsSeries = Tuple2([
      charts.Series<Tuple3, String>(
          id: "placements",
          data: placementsData,
          domainFn: (series, _) => series.item1.toString(),
          measureFn: (series, _) => series.item2,
          colorFn: (series, _) => charts.ColorUtil.fromDartColor(series.item3))
    ], _results.placements.item1.toString());

    List<Tuple3<int, int, Color>> videosData = [];
    videosData.add(Tuple3(1, _results.videos.item1, AppStyles.primaryColor));
    if (videosHasGoal) {
      videosData.add(Tuple3(2, _results.videos.item2, AppStyles.chartsUnusedColor));
    }

    _videosSeries = Tuple2([
      charts.Series<Tuple3, String>(
          id: "placements",
          data: videosData,
          domainFn: (series, _) => series.item1.toString(),
          measureFn: (series, _) => series.item2,
          colorFn: (series, _) => charts.ColorUtil.fromDartColor(series.item3))
    ], _results.videos.item1.toString());
  }

  Future navigateToAllReturnVisits(BuildContext context) async {
    var position = await _locationService.getCurrentOrLastKnownPosition();
    return showBarModalBottomSheet(
        context: context,
        builder: (_) => GenericCollectionScreen(
              title: "All Return Visits",
              itemPadding: EdgeInsets.symmetric(horizontal: AppStyles.leftMargin, vertical: 30.0),
              items: _results.rvEntries,
              itemBuilder: (rv) => ReturnVisitCard(
                returnVisit: ReturnVisitListItemModel(
                    returnVisit: rv,
                    currentLatitude: position.latitude,
                    currentLongitude: position.longitude),
              ),
            ));
  }

  void _buildTimeByDayChartData() {
    _timeByDayChartData = [0, 0, 0, 0, 0, 0, 0];
    List<Time> timeEntries = [];
    _results.timeEntries.forEach((key, value) => timeEntries.addAll(value));
    for (var time in timeEntries) {
      _timeByDayChartData[time.date.weekday - 1] += time.totalMinutes / 60;
    }
  }

  void setCustomDates(DateTime start, DateTime end) {
    _mode = ReportingMode.Custom;
    _loadData(start, end);
  }

  Future sendCurrentReport(BuildContext context) async {
    if (_results.isSingleMonth &&
        (_results.totalDuration.inMinutes % 60 != 0 ||
            _results.durationByCategories.item1.any((e) => e.time.inMinutes % 60 != 0))) {
      await confirmationDialog(
          context,
          "You currently have " +
              "${_results.durationByCategories.item1.firstWhere((e) => e.category.isMinistry)?.timeString} " +
              "Ministry hours and ${_results.totalDuration.toShortString()} total hours.\n\n " +
              "Do you want to forward the extra time to the next month?",
          title: "Forward time",
          positiveText: "Yes",
          positiveAction: () async {
            _ignoreUpdates = true;
            var failedCategories = await _timeService.forwardTime(_results.startDate);
            if (failedCategories.isNotEmpty) {
              await infoDialog(
                  context,
                  "Could not update the follow categories because they did not have enough time:\n" +
                      failedCategories.fold("", (p, e) => p + "${e.name}") +
                      "\n");
            }

            _ignoreUpdates = false;
            await _loadData(_start, _end);

            await _reportingService.sendExistingReport(_results);
          },
          negativeText: "No",
          negativeAction: () => _reportingService.sendExistingReport(_results),
          showNeutralButton: false,
          confirm: false);
      return;
    } else {
      _reportingService.sendExistingReport(_results);
    }
  }
}

enum ReportingMode { CurrentMonth, LastMonth, ServiceYear, Custom }

class ReturnVisitSummaryItem extends Navigatable {
  /// The [summary] of item.
  final String summary;

  /// The [count] of the item.
  final int count;

  /// The [iconPath] for the item.
  final String iconPath;

  /// The [icon] to use. If supplied, it overrides the [iconPath].
  final IconData icon;

  final Future Function(BuildContext) onNavigate;

  ReturnVisitSummaryItem(
      {@required this.summary,
      @required this.count,
      this.icon,
      this.iconPath,
      @required this.onNavigate});

  @override
  Future navigate(BuildContext context) async {
    await onNavigate(context);
  }
}
