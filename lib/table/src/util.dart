import 'dart:math';

import 'package:meta/meta.dart';

@immutable
class Overlap {
  const Overlap(this.index, this.amount);

  final int index;
  final double amount;

  @override
  String toString() => '($index, $amount)';
}

List<Overlap> overlap({
  @required double draggableY,
  @required double draggableHeight,
  @required double tableScrollAmount,
  @required List<double> rowHeights,
}) {
  final draggableTop = tableScrollAmount + draggableY;
  final draggableBottom = draggableTop + draggableHeight;

  final result = <Overlap>[];

  var i = 0;
  var overlapAmount = 0.0;
  var offset = 0.0;
  while (i < rowHeights.length) {
    final rowTop = offset;
    final rowBottom = offset + rowHeights[i];

    final overlapBottom = min(draggableBottom, rowBottom);
    final overlapTop = max(draggableTop, rowTop);
    final overlapHeight = overlapBottom - overlapTop;

    if (overlapHeight > 0) {
      overlapAmount = overlapHeight / rowHeights[i];
      result.add(Overlap(i, overlapAmount));
    } else if (overlapAmount > 0) {
      break;
    }
    offset += rowHeights[i];
    i++;
  }

  return result;
}

int pinnedSectionTitleIndex({
  @required double tableScrollAmount,
  @required List<double> rowHeights,
  @required List<int> sectionTitlePositions,
}) {
  if (rowHeights.isEmpty || sectionTitlePositions.isEmpty) {
    return -1;
  }

  var scrollOffset = 0.0;
  var pinnedIndex = -1;
  for (var i = 0;
      i < rowHeights.length && scrollOffset <= tableScrollAmount;
      i++) {
    if (sectionTitlePositions.contains(i)) {
      pinnedIndex = i;
    }
    scrollOffset += rowHeights[i];
  }

  return pinnedIndex;
}
