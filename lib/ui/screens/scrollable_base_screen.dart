import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:jama/mixins/color_mixin.dart';
import 'package:jama/ui/app_styles.dart';
import 'dart:math';

class ScrollableBaseScreen extends StatefulWidget {
  final PreferredSizeWidget headerWidget;
  final PreferredSizeWidget headerBottomWidget;
  final PreferredSizeWidget floatingWidget;
  final bool hideFloatingWidgetOnScroll;
  final AnimatedIconData speedDialIcon;
  final List<SpeedDialChild> speedDialActions;
  final Widget body;

  ScrollableBaseScreen({Key key, this.headerWidget, this.headerBottomWidget, this.floatingWidget, this.hideFloatingWidgetOnScroll = true, this.speedDialIcon, this.speedDialActions, this.body}) : super(key: key);

  @override
  _ScrollableBaseWidgetState createState() => _ScrollableBaseWidgetState();
}

class _ScrollableBaseWidgetState extends State<ScrollableBaseScreen> {
  double minimumHeight;
  double maximumHeight;
  double headerHeight;
  double halfOfFloatingWidgetHeight;

  ScrollController scrollController;

  bool _didUpdateByScroll = false;
  
  @override
  void initState() {
    _updateMinMaxHeight();
    
    headerHeight = maximumHeight;
    
    scrollController = ScrollController(keepScrollOffset: true);
    scrollController.addListener(() => setState(() {
      _didUpdateByScroll = true;
      headerHeight = max(minimumHeight, maximumHeight - max(scrollController.offset, 0));
    }));
    super.initState();
  }

  @override
  void dispose() { 
    scrollController.dispose();
    super.dispose();
  }

  @override


  @override
  Widget build(BuildContext context) {
    _updateMinMaxHeight();
    
    double opacity = 0.0;
    if(headerHeight - minimumHeight > 0 && maximumHeight - minimumHeight >= 0) {
      opacity = (headerHeight - minimumHeight) / (maximumHeight - minimumHeight);
    }
    return Scaffold(
      floatingActionButton: widget.speedDialActions == null || widget.speedDialActions.length <= 0
        ? null
        : SpeedDial(
        marginBottom: MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + headerHeight) - 28,
        foregroundColor: AppStyles.secondaryBackground,
        backgroundColor: Colors.white,
        animatedIcon: widget.speedDialIcon,
        overlayColor: HexColor.fromHex("#9F9F9F"),
        overlayOpacity: 0.7,
        orientation: SpeedDialOrientation.Down,
        children: widget.speedDialActions
      ),
       body: Stack(
         children: <Widget>[
        Positioned(
          top: 0, 
          child: Container(
            height: headerHeight + MediaQuery.of(context).padding.top,
            width: MediaQuery.of(context).size.width,
            color: AppStyles.secondaryBackground,
            child: Wrap(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if(widget.headerWidget != null) widget.headerWidget,
                      if(widget.headerBottomWidget != null) Opacity(
                        opacity: opacity,
                        child: widget.headerBottomWidget,),
                  ],),
                ),
              ],
            ),),),
        Positioned.fill(
            top:headerHeight + MediaQuery.of(context).padding.top,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: halfOfFloatingWidgetHeight + 10),),
                  widget.body,
                  Builder(builder: (c) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(c).padding.bottom + 20)))
                ],
              )),
          ),
        Positioned(
          top: MediaQuery.of(context).padding.top + headerHeight - halfOfFloatingWidgetHeight,
          width: MediaQuery.of(context).size.width,
          height: halfOfFloatingWidgetHeight * 2,
          child: widget.floatingWidget != null 
          ? widget.hideFloatingWidgetOnScroll 
            ? AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: (headerHeight - minimumHeight) / (maximumHeight - minimumHeight) <= 0.8
                ? 0.0
                : 1.0,
              child: widget.floatingWidget,
            )
            : widget.floatingWidget 
          : Container(),
        )
       ],),
    );
  }

  void _updateMinMaxHeight() {
    var headerWidgetHeight = widget.headerWidget == null 
      ? 0 
      : widget.headerWidget.preferredSize.height;
    var headerBottomWidgetHeight = widget.headerBottomWidget == null 
      ? 0 
      : widget.headerBottomWidget.preferredSize.height;
    var floatingWidgetHeight = widget.floatingWidget == null
      ? 0 
      : widget.floatingWidget.preferredSize.height;
    halfOfFloatingWidgetHeight = floatingWidgetHeight <= 0 
      ? 0
      : floatingWidgetHeight / 2;
    
    minimumHeight = max(
          kToolbarHeight, 
          headerWidgetHeight + halfOfFloatingWidgetHeight);
    
    maximumHeight = max(
      kToolbarHeight, 
      minimumHeight + headerBottomWidgetHeight + halfOfFloatingWidgetHeight);

    if(!_didUpdateByScroll) {
      headerHeight = maximumHeight;
    } else {
      _didUpdateByScroll = false;
    }
  }
}