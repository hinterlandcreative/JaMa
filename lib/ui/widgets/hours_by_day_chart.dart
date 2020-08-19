import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jama/ui/app_styles.dart';

class HoursByDayChart extends StatefulWidget {
  final List<double> chartData;
  const HoursByDayChart({
    Key key,
    this.chartData,
  }) : super(key: key);

  @override
  _HoursByDayChartState createState() => _HoursByDayChartState();
}

class _HoursByDayChartState extends State<HoursByDayChart> {
  int touchedIndex;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: AppStyles.primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                'Hours',
                style:
                    AppStyles.heading2.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                'Hours by day',
                style: AppStyles.smallTextStyle.copyWith(color: AppStyles.lightGrey),
              ),
              const SizedBox(
                height: 38,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: BarChart(
                    _createBarData(),
                    swapAnimationDuration: Duration(milliseconds: 300),
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartData _createBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              switch (group.x.toInt() + 1) {
                case DateTime.monday:
                  weekDay = 'Monday';
                  break;
                case DateTime.tuesday:
                  weekDay = 'Tuesday';
                  break;
                case DateTime.wednesday:
                  weekDay = 'Wednesday';
                  break;
                case DateTime.thursday:
                  weekDay = 'Thursday';
                  break;
                case DateTime.friday:
                  weekDay = 'Friday';
                  break;
                case DateTime.saturday:
                  weekDay = 'Saturday';
                  break;
                case DateTime.sunday:
                  weekDay = 'Sunday';
                  break;
              }
              var hours = (rod.y - 1).toString();
              if (hours.endsWith(".0")) {
                hours = hours.split('.').first;
              }

              return BarTooltipItem(weekDay + '\n' + hours + (rod.y - 1 == 1 ? " Hour" : " Hours"),
                  TextStyle(color: Colors.white));
            }),
        touchCallback: (barTouchResponse) {
          setState(() {
            if (barTouchResponse.spot != null &&
                barTouchResponse.touchInput is! FlPanEnd &&
                barTouchResponse.touchInput is! FlLongPressEnd) {
              touchedIndex = barTouchResponse.spot.touchedBarGroupIndex;
            } else {
              touchedIndex = -1;
            }
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt() + 1) {
              case DateTime.monday:
                return 'M';
              case DateTime.tuesday:
                return 'T';
              case DateTime.wednesday:
                return 'W';
              case DateTime.thursday:
                return 'T';
              case DateTime.friday:
                return 'F';
              case DateTime.saturday:
                return 'S';
              case DateTime.sunday:
                return 'S';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: _createGroups(),
    );
  }

  List<BarChartGroupData> _createGroups() {
    return List.generate(7, (i) {
      return createGroup(i, widget.chartData[i], isTouched: i == touchedIndex);
    });
  }

  BarChartGroupData createGroup(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          color: isTouched ? Colors.yellow : barColor,
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: 20,
            color: Color(0xffdbdbdb).withOpacity(0.20),
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }
}
