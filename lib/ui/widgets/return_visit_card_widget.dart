import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jama/ui/models/return_visits/return_visit_list_item_model.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

import '../app_styles.dart';

class ReturnVisitCard extends StatelessWidget {
  final bool ignoreNavigationRequests;
  final ReturnVisitListItemModel returnVisit;

  ReturnVisitCard({
    Key key, this.returnVisit, this.ignoreNavigationRequests = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actions: <Widget>[
        IconSlideAction(
          icon: Icons.calendar_today,
          color: Colors.green,
          caption: "add visit",
          onTap: () {},)
      ],
      secondaryActions: <Widget>[
          IconSlideAction(
            icon: Icons.delete_outline,
            color: Colors.red,
            caption: "delete",
            onTap: () => returnVisit.delete(),
          )
        ],
      child: ignoreNavigationRequests
      ? _buildCard()
      : GestureDetector(
        onTap: () => returnVisit.navigate(context),
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
        decoration: BoxDecoration(
          color: Color(0xffffffff),
          boxShadow: [
            BoxShadow(
              offset: Offset(1.00, 1.00),
              color: Color(0xff000000).withOpacity(0.16),
              blurRadius: 25,
            ),
          ],
          borderRadius: BorderRadius.circular(15.00),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Stack(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // returnVisit.imagePath.isNotEmpty
                //  ? Container(
                //   height: 69.00,
                //   width: 69.00,
                //   decoration: BoxDecoration(
                //     image: DecorationImage(
                //       image: AssetImage(
                //           returnVisit.imagePath),
                //     ),
                //     borderRadius:
                //         BorderRadius.circular(15.00),
                //   ),
                // ) :
                Container(
                  height: 69,
                  width: 69,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.cyan, AppStyles.primaryColor])),
                  child: Center(child: AutoSizeText(
                    returnVisit.nameOrDescription.substring(0,1).toUpperCase(),
                    style: AppStyles.heading1.copyWith(color: Colors.white),),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        returnVisit.nameOrDescription,
                        style: AppStyles.heading4.copyWith(
                            fontWeight: FontWeight.bold),
                      ),
                      Text(returnVisit.formattedAddress,
                          style: AppStyles.heading4)
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    returnVisit.timeSinceString.toUpperCase(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: "Avenir",
                      fontSize: 10,
                      color: returnVisit.timeSinceColor,
                    ),
                  ),
                  Text(
                    returnVisit.distanceFromCurrentLocation
                        .toUpperCase(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: "Avenir",
                      fontSize: 10,
                      color: AppStyles.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
                bottom: 0,
                right: 0,
                child: !returnVisit.isPinned 
                ? Container()
                : Icon(
                  Typicons.star, 
                  color: Colors.amber,))
          ]),
        ),
      );
  }
}
