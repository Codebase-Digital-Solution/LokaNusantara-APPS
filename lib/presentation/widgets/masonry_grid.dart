import 'package:flutter/material.dart';

/// Pinterest-style grid: items go to whichever column is currently shortest,
/// so tiles of different heights interlock instead of lining up in rows.
class MasonryGrid<T> extends StatelessWidget {
  const MasonryGrid({
    super.key,
    required this.items,
    required this.heightOf,
    required this.itemBuilder,
    this.columns = 2,
    this.spacing = 12,
  });

  final List<T> items;

  /// Estimated tile height, used only to balance the columns.
  final double Function(T item) heightOf;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int columns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final cols = List.generate(columns, (_) => <Widget>[]);
    final heights = List.filled(columns, 0.0);

    for (var i = 0; i < items.length; i++) {
      var target = 0;
      for (var c = 1; c < columns; c++) {
        if (heights[c] < heights[target]) target = c;
      }
      if (cols[target].isNotEmpty) cols[target].add(SizedBox(height: spacing));
      cols[target].add(itemBuilder(context, items[i], i));
      heights[target] += heightOf(items[i]) + spacing;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < columns; c++) ...[
          if (c > 0) SizedBox(width: spacing),
          Expanded(child: Column(children: cols[c])),
        ],
      ],
    );
  }
}
