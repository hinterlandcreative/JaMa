import 'package:flutter/material.dart';
import 'package:jama/ui/app_styles.dart';

class GenericCollectionScreen<W extends Widget, M> extends StatelessWidget  {
  final Iterable<M> items;
  final W Function(M) widgetBuilder;
  final bool wrapInScrollable;
  final EdgeInsets padding;
  final String title;

  const GenericCollectionScreen(
    {Key key, 
    @required this.items, 
    @required this.widgetBuilder, 
    this.padding = const EdgeInsets.all(0.0),
    this.wrapInScrollable = true, this.title,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var column = Column(
      children: items
        .map((i) => widgetBuilder(i))
        .toList());

    return Scaffold(
      appBar: title != null && title.isNotEmpty ? AppBar(
        backgroundColor: AppStyles.secondaryBackground,
        leading: BackButton(onPressed: () => Navigator.pop(context),),
        title: Text(title, style: AppStyles.heading1,)) : null,
       body: Padding(
        padding: padding,
        child: wrapInScrollable
          ? SingleChildScrollView(
            child: column)
          : column,),
    );
  }
}