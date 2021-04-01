import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:jama/mixins/color_mixin.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/models/time/root_time_page_model.dart';
import 'package:jama/ui/widgets/spacer.dart';
import 'package:jama/mixins/date_mixin.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:quiver/time.dart';
import 'package:table_calendar/table_calendar.dart';

import 'add_edit_time_screen.dart';

class RootTimeScreen extends StatefulWidget {
  RootTimeScreen({Key key}) : super(key: key);

  @override
  _RootTimeScreenState createState() => _RootTimeScreenState();
}

class _RootTimeScreenState extends State<RootTimeScreen> with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;
  CalendarController calendarController;
  var _currentMonth;

  List<TimeEntry> _entries;

  @override
  void initState() {
    calendarController = CalendarController();
    _currentMonth = DateTime.now().month;
    _entries = <TimeEntry>[];
    super.initState();
  }

  @override
  void dispose() {
    calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider(
      create: (context) => RootTimePageModel(),
      child: Consumer<RootTimePageModel>(
        builder: (context, model, _) {
          if (calendarController != null && calendarController.focusedDay != null) {
            _entries = model.getEntriesForDate(calendarController.focusedDay);
          }
          return Scaffold(
            backgroundColor: AppStyles.primaryColor,
            appBar: AppBar(
              backgroundColor: AppStyles.primaryColor,
              centerTitle: false,
              title: Text(
                "Time",
                style: AppStyles.heading1,
              ),
              elevation: 0,
            ),
            floatingActionButton: SpeedDial(
                marginBottom: MediaQuery.of(context).padding.bottom + 35.0,
                foregroundColor: AppStyles.primaryColor,
                backgroundColor: Colors.white,
                animatedIcon: AnimatedIcons.menu_close,
                overlayColor: HexColor.fromHex("#9F9F9F"),
                overlayOpacity: 0.7,
                orientation: SpeedDialOrientation.Up,
                children: [
                  SpeedDialChild(
                      child: Icon(Icons.add),
                      label: "add time",
                      labelStyle: AppStyles.heading4,
                      onTap: () {
                        showBarModalBottomSheet(
                            context: context,
                            builder: (context) => AddEditTimeScreen.create(
                                calendarController != null ? calendarController.focusedDay : null));
                      }),
                  SpeedDialChild(
                      child: Icon(Icons.access_alarms),
                      label: "record time",
                      labelStyle: AppStyles.heading4),
                ]),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                VerticalSpace(15.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppStyles.leftMargin),
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Color(0xffffffff),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(2.00, 2.00),
                            color: Color(0xff000000).withOpacity(0.16),
                            blurRadius: 12,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20.00),
                      ),
                      child: _buildCalendar(model)),
                ),
                _entries.isEmpty
                    ? Expanded(
                        child: Center(
                            child: Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                        child: Text(
                          "No time for this date.",
                          style: AppStyles.smallTextStyle.copyWith(color: Colors.white),
                        ),
                      )))
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppStyles.leftMargin),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _entries.length,
                          itemBuilder: (context, index) {
                            var entry = _entries[index];
                            return _buildTimeEntry(entry, context);
                          },
                        ),
                      )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeEntry(TimeEntry entry, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          IconSlideAction(
            icon: Icons.delete_forever,
            foregroundColor: Colors.red,
            color: Colors.transparent,
            caption: "delete",
            onTap: () => entry.delete(),
          )
        ],
        child: GestureDetector(
          onTap: () => entry.navigate(context),
          child: Row(
            children: [
              Container(
                width: 3.0,
                height: 30.0,
                color: entry.category.isMinistry ? Colors.white : entry.category.color,
              ),
              HorizontalSpace(15.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.category.name,
                    style: AppStyles.heading2
                        .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(entry.startAndEndTimeString,
                      style: AppStyles.smallTextStyle.copyWith(color: AppStyles.lightGrey))
                ],
              ),
              Expanded(
                child: Text(
                  entry.hoursString,
                  textAlign: TextAlign.end,
                  style: AppStyles.heading2.copyWith(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  TableCalendar _buildCalendar(RootTimePageModel model) {
    return TableCalendar(
      locale: Intl.systemLocale,
      calendarController: calendarController,
      startingDayOfWeek: StartingDayOfWeek.monday,
      onCalendarCreated: (first, last, _) async {
        await model.loadEntries(first, last);
        _entries = model.getEntriesForDate(calendarController.focusedDay);
      },
      onDaySelected: (date, _, __) => setState(() => _entries = model.getEntriesForDate(date)),
      onVisibleDaysChanged: (first, last, format) async {
        _currentMonth = _getCurrentMonth(first, last);
        await model.loadEntries(first, last);
        var dayMultiplier = 0;
        while (first.add(aDay * dayMultiplier).day != 1) {
          dayMultiplier++;
        }
        calendarController.setSelectedDay(first.add(aDay * dayMultiplier));
        setState(() {
          _entries = model.getEntriesForDate(calendarController.selectedDay);
        });
      },
      builders: CalendarBuilders(
          dowWeekdayBuilder: (context, weekday) => Text(
                weekday.toLowerCase().substring(0, 1),
                textAlign: TextAlign.center,
                style: AppStyles.smallTextStyle,
              ),
          dayBuilder: (context, date, events) {
            var entries = model.getEntriesForDate(date);
            return Stack(children: [
              Center(
                  child: Text(
                date.day.toString(),
                style: AppStyles.smallTextStyle
                    .copyWith(color: date.month == _currentMonth ? Colors.black : Colors.grey[400]),
              )),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: entries
                          .map(
                            (e) => e.category,
                          )
                          .toSet()
                          .map((e) => Container(
                                height: 5.00,
                                width: 5.00,
                                decoration: BoxDecoration(
                                  color: e.color,
                                  shape: BoxShape.circle,
                                ),
                              ))
                          .toList(),
                    ),
                  ))
            ]);
          },
          todayDayBuilder: (context, date, _) {
            var entries = model.getEntriesForDate(date);
            return Stack(children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: CircleAvatar(
                  backgroundColor: AppStyles.primaryColor.withAlpha(70),
                  child: Text(date.day.toString(),
                      style: AppStyles.smallTextStyle.copyWith(color: Colors.black)),
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: entries
                          .map(
                            (e) => e.category,
                          )
                          .toSet()
                          .map((e) => Container(
                                height: 5.00,
                                width: 5.00,
                                decoration: BoxDecoration(
                                  color: e.color,
                                  shape: BoxShape.circle,
                                ),
                              ))
                          .toList(),
                    ),
                  ))
            ]);
          },
          selectedDayBuilder: (context, date, _) {
            var entries = model.getEntriesForDate(date);
            return Container(
                decoration: BoxDecoration(
                  color: Color(0xffdbdbdb),
                  borderRadius: BorderRadius.circular(5.00),
                ),
                child: Stack(children: [
                  Center(
                      child: Text(
                    date.day.toString(),
                    style: AppStyles.smallTextStyle.copyWith(
                        color: date.month == _currentMonth ? Colors.black : Colors.grey[400]),
                  )),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: entries
                              .map(
                                (e) => e.category,
                              )
                              .toSet()
                              .map((e) => Container(
                                    height: 5.00,
                                    width: 5.00,
                                    decoration: BoxDecoration(
                                      color: e.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ))
                ]));
          }),
      headerStyle: HeaderStyle(
          formatButtonVisible: false,
          leftChevronMargin: EdgeInsets.zero,
          leftChevronPadding: EdgeInsets.zero,
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
          rightChevronMargin: EdgeInsets.zero,
          rightChevronPadding: EdgeInsets.zero,
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
          titleTextStyle: AppStyles.heading1.copyWith(color: Colors.black)),
    );
  }

  int _getCurrentMonth(DateTime first, DateTime last) {
    if (first.month == last.month) return first.month;
    if (first.day == 1) return first.month;
    if (last.month == 1 && first.month == 11) return 12;
    if (last.month - first.month > 1) return first.month + 1;
    if (last.day == last.toLastDayOfMonth().day) return last.month;
    return 0;
  }
}
