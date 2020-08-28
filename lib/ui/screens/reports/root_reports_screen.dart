import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/models/reporting/reporting_page_model.dart';
import 'package:jama/ui/models/time/time_by_date_model.dart';
import 'package:jama/ui/models/time/time_modification_model.dart';
import 'package:jama/ui/widgets/donut_chart_widget.dart';
import 'package:jama/ui/widgets/hours_by_day_chart.dart';
import 'package:jama/ui/widgets/spacer.dart';
import 'package:jama/ui/widgets/time_card_collection.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:jama/mixins/date_mixin.dart';

class RootReportsScreen extends StatefulWidget {
  const RootReportsScreen({Key key}) : super(key: key);

  @override
  _RootReportsScreenState createState() => _RootReportsScreenState();
}

class _RootReportsScreenState extends State<RootReportsScreen> with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;
  ItemScrollController modePickerScrollController;

  @override
  void initState() {
    modePickerScrollController = ItemScrollController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportingPageModel.currentMonth(),
      child: Consumer<ReportingPageModel>(
        builder: (context, model, _) => Scaffold(
          backgroundColor: AppStyles.primaryBackground,
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20.0),
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () => model.sendCurrentReport(context),
              child: Icon(
                Icons.send,
                color: AppStyles.primaryColor,
              ),
            ),
          ),
          appBar: AppBar(
            backgroundColor: AppStyles.primaryBackground,
            elevation: 0,
            title: Text("Report", style: AppStyles.heading1.copyWith(color: Colors.black)),
            centerTitle: false,
          ),
          body: model.isLoading
              ? _buildLoading()
              : !model.hasReport
                  ? _buildEmptyState(context)
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModePicker(context, model),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: AppStyles.leftMargin),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    VerticalSpace(23.0),
                                    Text(model.entryMessage,
                                        style: AppStyles.paragraph
                                            .copyWith(color: AppStyles.captionText)),
                                    VerticalSpace(16.0),
                                    _buildTotalTime(context, model),
                                    if (model.timeGoalsByCategory.length > 1) VerticalSpace(16.0),
                                    if (model.timeGoalsByCategory.length > 1)
                                      _buildTimeByCategory(context, model),
                                    VerticalSpace(30.0),
                                    Text("PLACEMENTS", style: AppStyles.heading3),
                                    VerticalSpace(20.0),
                                    _buildPlacementsCharts(context, model),
                                    VerticalSpace(30.0),
                                    Text("RETURN VISITS", style: AppStyles.heading3),
                                    VerticalSpace(20.0),
                                    _buildReturnVisitSummaries(context, model),
                                    VerticalSpace(30.0),
                                    Text("ENTRIES", style: AppStyles.heading3),
                                    VerticalSpace(20.0),
                                    _buildEntriesByDayChart(context, model),
                                    VerticalSpace(30.0),
                                  ],
                                ),
                              ),
                              _buildTimeEntriesList(context, model),
                              VerticalSpace(100.0)
                            ],
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Center _buildLoading() {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 50.0,
          width: 50.0,
          child: LoadingIndicator(
            indicatorType: Indicator.audioEqualizer,
            color: AppStyles.primaryColor,
          ),
        ),
        Text("Loading Report...", style: AppStyles.heading3)
      ],
    ));
  }

  Widget _buildModePicker(BuildContext context, ReportingPageModel model) {
    return Container(
      height: 33.0,
      width: MediaQuery.of(context).size.width,
      child: ScrollablePositionedList.builder(
          scrollDirection: Axis.horizontal,
          itemScrollController: modePickerScrollController,
          itemCount: model.availableReportingModes.length,
          initialScrollIndex: model.availableReportingModes
              .indexWhere((element) => element.item1 == model.currentReportingMode),
          itemBuilder: (context, index) {
            var mode = model.availableReportingModes[index];
            var isCurrentMode = model.currentReportingMode == mode.item1;
            return GestureDetector(
              child: Padding(
                padding: isCurrentMode
                    ? EdgeInsets.only(left: index == 0 ? 10.0 : 0.0)
                    : EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 7.0, horizontal: isCurrentMode ? 10.0 : 0.0),
                  decoration: BoxDecoration(
                    color: isCurrentMode ? Color(0xff5385e5).withOpacity(0.20) : Colors.transparent,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Text(
                    mode.item2,
                    style: AppStyles.smallTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCurrentMode ? AppStyles.primaryColor : AppStyles.captionText),
                  ),
                ),
              ),
              onTap: () async {
                if (mode.item1 == ReportingMode.Custom) {
                  final picked = await showDateRangePicker(
                      context: context,
                      initialDateRange: DateTimeRange(
                          start: DateTime.now().toFirstDayOfMonth(),
                          end: DateTime.now().toLastDayOfMonth()),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().toLastDayOfMonth());
                  if (picked != null) {
                    model.setCustomDates(picked.start, picked.end);
                  }
                } else {
                  model.currentReportingMode = mode.item1;
                }
              },
            );
          }),
    );
  }

  Widget _buildTotalTime(BuildContext context, ReportingPageModel model) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(model.timeTotal,
            style: TextStyle(
              fontFamily: "Avenir",
              fontSize: 34,
              color: Colors.black,
            )),
        if (model.timeHasGoal)
          Padding(
            padding: const EdgeInsets.only(left: 6.0, bottom: 8.0),
            child: Text("/ ${model.timeGoal}", style: AppStyles.smallTextStyle),
          )
      ],
    );
  }

  Widget _buildTimeByCategory(BuildContext context, ReportingPageModel model) {
    return Container(
      height: 50.0,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: model.timeGoalsByCategory.length,
          itemBuilder: (context, index) {
            var item = model.timeGoalsByCategory[index];
            return Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.category.name,
                      style: AppStyles.smallTextStyle.copyWith(fontWeight: FontWeight.bold)),
                  VerticalSpace(2.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(height: 18.0, width: 3.00, color: item.category.color),
                      HorizontalSpace(5.0),
                      Text(item.timeString, style: AppStyles.heading2)
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }

  Widget _buildPlacementsCharts(BuildContext context, ReportingPageModel model) {
    return !model.videosHasValue && !model.placementsHasValue
        ? Container(
            height: 70,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text("No placements or videos for ${model.currentReportingModeString}."),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (model.placementsHasValue)
                Column(
                  children: [
                    DonutChartWidget(
                      model.placementsSeries.item1,
                      height: 70,
                      width: 70,
                      text: model.placementsSeries.item2,
                      textStyle: AppStyles.heading2,
                    ),
                    VerticalSpace(8.0),
                    Text(
                      "Placements",
                      style: AppStyles.heading2,
                    )
                  ],
                ),
              if (model.videosHasValue)
                Column(
                  children: [
                    DonutChartWidget(
                      model.videosSeries.item1,
                      height: 70,
                      width: 70,
                      text: model.videosSeries.item2,
                      textStyle: AppStyles.heading2,
                    ),
                    VerticalSpace(8.0),
                    Text(
                      "Videos",
                      style: AppStyles.heading2,
                    )
                  ],
                )
            ],
          );
  }

  Widget _buildReturnVisitSummaries(BuildContext context, ReportingPageModel model) {
    var spacing = 21.0;
    var boxWidth = ((MediaQuery.of(context).size.width - (AppStyles.leftMargin * 2)) / 2) - 21.0;

    return Wrap(
      alignment: WrapAlignment.start,
      spacing: spacing,
      runSpacing: spacing,
      children: model.rvSummaryItems
              .map((rv) => GestureDetector(
                  onTap: () => rv.onNavigate(context),
                  child: Container(
                      height: 95.00,
                      width: boxWidth,
                      decoration: BoxDecoration(
                        color: Color(0xffdbdbdb),
                        borderRadius: BorderRadius.circular(15.00),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 17.0, left: 17.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: rv.icon != null
                                  ? Icon(rv.icon, size: 20.0)
                                  : Image(
                                      width: 20,
                                      height: 20,
                                      image: AssetImage(rv.iconPath),
                                    ),
                            ),
                            HorizontalSpace(10.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  rv.count.toString(),
                                  style: AppStyles.heading2,
                                ),
                                Container(
                                  width: 92,
                                  child: Text(
                                    rv.summary,
                                    style: AppStyles.smallTextStyle,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ))))
              .toList() +
          [
            GestureDetector(
              onTap: () => model.navigateToAllReturnVisits(context),
              child: Container(
                  height: 95.00,
                  width: boxWidth,
                  decoration: BoxDecoration(
                    color: AppStyles.primaryColor,
                    borderRadius: BorderRadius.circular(15.00),
                  ),
                  child: Center(
                    child: Text("VIEW ALL",
                        style: AppStyles.heading3.copyWith(color: Colors.white, fontSize: 10.0)),
                  )),
            )
          ],
    );
  }

  Widget _buildEntriesByDayChart(BuildContext context, ReportingPageModel model) {
    return HoursByDayChart(chartData: model.timeByDayChartData);
  }

  Widget _buildTimeEntriesList(BuildContext context, ReportingPageModel model) {
    var items = model.timeEntries.entries
        .map((e) => TimeByDateModel(
            e.value.map((t) => TimeModificationModel.edit(time: t)).toList(), e.key))
        .toList();
    return TimeCardCollection(onItemDeleted: (t) => t.delete(), items: UnmodifiableListView(items));
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.alarm_add,
            color: AppStyles.captionText,
            size: 50.0,
          ),
          VerticalSpace(15.0),
          SizedBox(
            width: min(200.0, MediaQuery.of(context).size.width / 2),
            child: Text(
              "You have no time or return visits for this period.",
              textAlign: TextAlign.center,
              style: AppStyles.heading4.copyWith(
                color: AppStyles.captionText,
              ),
            ),
          )
        ],
      ),
    );
  }
}
