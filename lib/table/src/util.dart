import 'dart:math';

import 'package:meta/meta.dart';

@immutable
class Overlap {
  final int index;
  final double amount;

  Overlap(this.index, this.amount);

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

  int i = 0;
  double overlapAmount = 0;
  double offset = 0;
  while (i < rowHeights.length) {
    final overlapHeight = min(draggableBottom, offset + rowHeights[i]) -
        max(draggableTop, offset);

    if (overlapHeight > 0) {
      overlapAmount = overlapHeight / rowHeights[i];
      result.add(Overlap(i, overlapAmount));
    } else if (overlapAmount > 0) {
      break;
    }
    i++;
    offset += rowHeights[i];
  }

  print('${result}');
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
