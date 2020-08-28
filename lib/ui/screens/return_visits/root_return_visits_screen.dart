import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/models/return_visits/all_return_visits_list_model.dart';
import 'package:jama/ui/models/return_visits/return_visit_list_item_model.dart';
import 'package:jama/ui/screens/generic_collection_screen.dart';
import 'package:jama/ui/screens/scrollable_base_screen.dart';
import 'package:jama/ui/widgets/grouped_return_visit_list_view.dart';
import 'package:jama/ui/widgets/return_visit_card_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:search_widget/search_widget.dart';

import 'add_return_visit_screen.dart';

class RootReturnVisitsScreen extends StatefulWidget {
  RootReturnVisitsScreen({Key key}) : super(key: key);

  @override
  _RootReturnVisitsScreenState createState() => _RootReturnVisitsScreenState();
}

class _RootReturnVisitsScreenState extends State<RootReturnVisitsScreen>
    with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AllReturnVisitsListModel(),
      child: Consumer<AllReturnVisitsListModel>(
        builder: (context, model, _) => ScrollableBaseScreen(
          speedDialIcon: AnimatedIcons.menu_close,
          speedDialActions: [
            SpeedDialChild(
                child: Icon(Icons.group_add),
                label: "add return visit",
                labelStyle: AppStyles.heading4,
                onTap: () {
                  showBarModalBottomSheet(
                      context: context, builder: (context, _) => AddReturnVisitScreen());
                }),
          ],
          headerWidget: _buildHeaderWidget(),
          headerBottomWidget: model.pinnedReturnVisits.length > 0
              ? _buildPinnedReturnVisitsWidget(context, items: model.pinnedReturnVisits)
              : null,
          floatingWidget: _buildSearchWidget(context),
          hideFloatingWidgetOnScroll: false,
          body: _buildBody(),
        ),
      ),
    );
  }

  Consumer<AllReturnVisitsListModel> _buildBody() {
    return Consumer<AllReturnVisitsListModel>(
      builder: (context, model, __) {
        if (model.hasItems) {
          return GroupedReturnVisitListView(collection: model.groupedCollection);
        } else {
          return Center(
            child: Text("No Return Visits."),
          );
        }
      },
    );
  }

  PreferredSize _buildSearchWidget(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 50.00),
      child: Padding(
        padding:
            EdgeInsets.only(left: AppStyles.leftMargin, right: 56.0 + (AppStyles.leftMargin * 2)),
        child: Consumer<AllReturnVisitsListModel>(
          builder: (context, model, __) => SearchWidget<ReturnVisitListItemModel>(
              dataList: model.returnVisits,
              textFieldBuilder: (controller, focusNode) {
                return Container(
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    border: Border.all(
                      width: 1.00,
                      color: Color(0xffd9d9d9),
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(1.00, 1.00),
                        color: Color(0xff000000).withOpacity(0.16),
                        blurRadius: 25,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10.00),
                  ),
                  child: ForceFocusWatcher(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                          hintText: "Search...",
                          hintStyle: AppStyles.heading4,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                          border: InputBorder.none),
                    ),
                  ),
                );
              },
              queryBuilder: (query, _) => model.search(query),
              popupListItemBuilder: (item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () => item.navigate(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.nameOrDescription,
                            style: AppStyles.smallTextStyle.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item.formattedAddress,
                            style: AppStyles.smallTextStyle,
                          )
                        ],
                      ),
                    ),
                  ),
              selectedItemBuilder: (item, _) => Container()),
        ),
      ),
    );
  }

  PreferredSize _buildPinnedReturnVisitsWidget(BuildContext context,
      {UnmodifiableListView<ReturnVisitListItemModel> items}) {
    return PreferredSize(
      preferredSize: Size.fromHeight(156.0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppStyles.leftMargin),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => GenericCollectionScreen(
                    title: "Pinned Return Visits",
                    items: items,
                    itemBuilder: (m) => Padding(
                          padding: EdgeInsets.only(
                              left: AppStyles.leftMargin,
                              right: AppStyles.leftMargin,
                              bottom: 17.0),
                          child: ReturnVisitCard(
                            returnVisit: m,
                          ),
                        ),
                    itemPadding: EdgeInsets.symmetric(
                      vertical: AppStyles.topMargin,
                    ))));
          },
          child: SizedBox(
              height: 156.0,
              width: MediaQuery.of(context).size.width - (AppStyles.leftMargin * 2),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    child: Text(
                      "Pinned",
                      style: AppStyles.heading4.copyWith(color: Colors.white),
                    ),
                  ),
                  Positioned.fill(
                      top: 37.0,
                      left: 22.0,
                      right: 22.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(15.00),
                        ),
                      )),
                  Positioned.fill(
                      top: 42.0,
                      bottom: 12.0,
                      left: 9.0,
                      right: 9.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white60,
                          borderRadius: BorderRadius.circular(15.00),
                        ),
                      )),
                  Positioned.fill(
                      top: 37.0,
                      bottom: 25.0,
                      child: ReturnVisitCard(
                        returnVisit: items.first,
                        ignoreNavigationRequests: true,
                      )),
                ],
              )),
        ),
      ),
    );
  }

  PreferredSize _buildHeaderWidget() {
    return PreferredSize(
      preferredSize: Size.fromHeight(46.0),
      child: Padding(
        padding: EdgeInsets.only(left: AppStyles.leftMargin),
        child: Text(
          "Return Visits",
          style: AppStyles.heading1.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
