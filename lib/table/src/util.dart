import 'dart:math';

import 'package:meta/meta.dart';

@immutable
class Overlap {
  final int index;
  final double amount;

  Overlap(this.index, this.amount);
}

List<Overlap> overlap({
  @required double draggableY,
  @required double draggableHeight,
  @required double tableScrollAmount,
  @required List<double> rowOffsets,
  @required List<double> rowHeights,
}) {
  assert(rowOffsets.length == rowHeights.length);
  final draggableTop = tableScrollAmount + draggableY;
  final draggableBottom = draggableTop + draggableHeight;

  final result = <Overlap>[];

  int i = 0;
  double overlapAmount = 0;
  while (i < rowOffsets.length) {
    final overlapHeight = min(draggableBottom, rowOffsets[i] + rowHeights[i]) -
        max(draggableTop, rowOffsets[i]);

    if (overlapHeight > 0) {
      overlapAmount = overlapHeight / rowHeights[i];
      result.add(Overlap(i, overlapAmount));
    } else if (overlapAmount > 0) {
      break;
    }
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

  double scrollOffset = 0;
  int pinnedIndex = -1;
  for (int i = 0;
      i < rowHeights.length && scrollOffset <= tableScrollAmount;
      i++) {
    if (sectionTitlePositions.contains(i)) {
      pinnedIndex = i;
    }
    scrollOffset += rowHeights[i];
  }

  return pinnedIndex;
}
