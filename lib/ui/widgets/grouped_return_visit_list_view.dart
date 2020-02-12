import 'package:flutter/material.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/models/return_visits/grouped_return_visit_collection_model.dart';
import 'package:jama/ui/models/return_visits/return_visit_list_item_model.dart';
import 'package:jama/ui/widgets/return_visit_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class GroupedReturnVisitListView extends StatelessWidget {

  final GroupedReturnVisitCollection<ReturnVisitListItemModel> collection;

  /// This widget must be wrapped in a [ListView] or [Scrollable] or it will potentially overrun the bottom of the screen.
  const GroupedReturnVisitListView({Key key, this.collection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: collection,
        child: Consumer<GroupedReturnVisitCollection<ReturnVisitListItemModel>>(
          builder: (_, model, __) => model.items.length <= 0
              ? Container()
              : Builder(builder: (_) {
                var children = <Widget>[];
                for(var section in model.items) {
                  if(section.items.length <= 0) continue;

                  children.add(StickyHeader(
                    header: Padding(
                      padding: EdgeInsets.only(left: 5.0, top: 10.0, bottom: 3.0),
                      child: Text(section.header,
                          style: AppStyles.heading2
                              .copyWith(fontWeight: FontWeight.bold)),
                    ),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: section.items.map((rv) => Padding(
                          padding: EdgeInsets.only(
                              left: AppStyles.leftMargin, 
                              right: AppStyles.leftMargin,
                              top: rv == section.items.first ? 0 : 17),
                          child: ReturnVisitCard(returnVisit: rv),
                        )).toList(),
                    )));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,);
              })
        ));
  }
}

