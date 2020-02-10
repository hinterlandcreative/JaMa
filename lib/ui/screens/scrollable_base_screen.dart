import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:jama/mixins/color_mixin.dart';
import 'package:jama/ui/app_styles.dart';

class ScrollableBaseWidget extends StatefulWidget {

  final AnimatedIconData speedDialIcon;
  final List<SpeedDialChild> speedDialActions;
  final Widget header;
  final Widget floatingWidget;
  final double floatingWidgetHeight;
  final Widget body;

  const ScrollableBaseWidget({Key key, this.speedDialIcon, this.speedDialActions, this.header, this.floatingWidget, this.body, this.floatingWidgetHeight}) : super(key: key);

  @override
  _ScrollableBaseWidgetState createState() => _ScrollableBaseWidgetState();
}

class _ScrollableBaseWidgetState extends State<ScrollableBaseWidget> {
  ScrollController _mainScrollController;

  final double _minimumHeaderSize = 75.0;

  double _percentScrolled = 0.0;
  double _bodyPositionY = 75.0;

  double get _heightLeft => (1.0 - _percentScrolled) * 100.0;

  @override
  void initState() {
    super.initState();

    _bodyPositionY = (kToolbarHeight + _heightLeft + _minimumHeaderSize);

    _mainScrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _percentScrolled = _mainScrollController.offset /
              _mainScrollController.position.maxScrollExtent;

          if (_percentScrolled < 0.0) _percentScrolled = 0.0;
          if (_percentScrolled > 1.0) _percentScrolled = 1.0;
          _bodyPositionY = (kToolbarHeight + _heightLeft + _minimumHeaderSize);
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.primaryBackground,
      floatingActionButton: SpeedDial(
        marginBottom: MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + _bodyPositionY) - 28,
        foregroundColor: AppStyles.secondaryBackground,
        backgroundColor: Colors.white,
        animatedIcon: widget.speedDialIcon,
        overlayColor: HexColor.fromHex("#9F9F9F"),
        overlayOpacity: 0.7,
        orientation: SpeedDialOrientation.Down,
        children: widget.speedDialActions
      ),
      body: Stack(children: <Widget>[
        NestedScrollView(
          controller: _mainScrollController,
          headerSliverBuilder: (context, isBodyScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: AppStyles.primaryColor,
                pinned: true,
                floating: true,
                forceElevated: isBodyScrolled,
                bottom: PreferredSize(
                  child: Container(
                    padding: EdgeInsets.only(left: AppStyles.leftMargin),
                    height: _heightLeft + _minimumHeaderSize,
                    alignment: Alignment.topLeft,
                    child: widget.header
                  ),
                  preferredSize: Size(
                    MediaQuery.of(context).size.width,
                    _heightLeft + _minimumHeaderSize)))
            ];
          },
          body: widget.body),
        if (widget.floatingWidget != null && widget.floatingWidgetHeight > 0.0) Positioned(
            top: MediaQuery.of(context).padding.top + _bodyPositionY - (widget.floatingWidgetHeight / 2),
            left: AppStyles.leftMargin,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _percentScrolled >= 0.1 ? 0.0 : 1.0,
              child: widget.floatingWidget
            ),
          ),
      ]),
    );
  }
}
