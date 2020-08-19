import 'package:flutter/material.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/widgets/spacer.dart';

class GenericCollectionScreen<W extends Widget, M> extends StatelessWidget {
  final Iterable<M> items;
  final W Function(M) itemBuilder;
  final bool wrapInScrollable;
  final EdgeInsets itemPadding;
  final double topSpacing;
  final double bottomSpacing;
  final String title;

  const GenericCollectionScreen({
    Key key,
    @required this.items,
    @required this.itemBuilder,
    this.itemPadding = const EdgeInsets.all(0.0),
    this.wrapInScrollable = true,
    this.title,
    this.topSpacing,
    this.bottomSpacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var column = Column(
        children: items.map((i) => Padding(padding: itemPadding, child: itemBuilder(i))).toList());

    return Scaffold(
      appBar: title != null && title.isNotEmpty
          ? AppBar(
              backgroundColor: AppStyles.secondaryBackground,
              leading: BackButton(
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                title,
                style: AppStyles.heading2,
              ))
          : null,
      body: Column(
        children: [
          if (topSpacing ?? 0 > 0) VerticalSpace(topSpacing),
          wrapInScrollable ? SingleChildScrollView(child: column) : column,
          if (bottomSpacing ?? 0 > 0) VerticalSpace(bottomSpacing)
        ],
      ),
    );
  }
}
