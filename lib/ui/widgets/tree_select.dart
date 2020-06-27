import 'package:flutter/material.dart';

import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/models/node.dart';
import 'package:jama/ui/transitions/slide_and_fade_transition.dart';

class TreeSelect extends StatefulWidget {
  final Node node;
  final Function(List<Node>) onSelectionMade;
  TreeSelect({Key key, @required this.node, this.onSelectionMade}) : super(key: key);

  @override
  _TreeSelectState createState() => _TreeSelectState();
}

class _TreeSelectState extends State<TreeSelect> {
  Node selectedNode;

  @override
  void initState() {
    super.initState();
  }

  @override
  @override
  void didUpdateWidget (TreeSelect oldWidget) {
    if(widget.node != oldWidget.node) {
      selectedNode = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SlideAndFadeTransition(
          id: widget.node.content,
          direction: AxisDirection.right,
          offset: 1.0,
          delay: 100,
          curve: Curves.ease,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: AppStyles.primaryColor,
              borderRadius: BorderRadius.circular(10.0)
            ),
            child: DropdownButton<Node>(
              underline: Container(),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.white,),
              isExpanded: true,
              hint: Align(
                alignment: Alignment.centerLeft,
                child: Text("Choose ${widget.node.content}", style: AppStyles.heading4.copyWith(color: Colors.white))),
              value: selectedNode,
              selectedItemBuilder: (_) => widget.node.children != null && widget.node.children.isNotEmpty
                ? widget.node.children.map<Widget>((n) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    n.content, 
                    style: AppStyles.heading4.copyWith(color: Colors.white)))).toList()
                : [],
              items: widget.node.children
                .map((n) => DropdownMenuItem<Node>(
                  value: n,
                  child: Text(n.content)))
                .toList(),
              onChanged: (node) {
                setState(() => selectedNode = node);
                widget.onSelectionMade([node]);
              },),
          ),
        ),
        Container(height: 15.0,),
        if(selectedNode != null && selectedNode.children != null && selectedNode.children.isNotEmpty) TreeSelect(
          node: selectedNode,
          onSelectionMade: (childNodes) => widget.onSelectionMade(childNodes..insert(0, selectedNode)),)
       ]
    );
  }
}