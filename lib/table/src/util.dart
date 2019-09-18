import 'package:meta/meta.dart';

int overlapIndex({
  @required double draggableY,
  @required double draggableHeight,
  @required double tableScrollAmount,
  @required List<double> rowOffsets,
  @required List<double> rowHeights,
  @required List<int> sectionTitlePositions,
}) {
  assert(rowOffsets.length == rowHeights.length);
  final headerHeight = rowHeights[0];
  final pinnedSectionIndex = pinnedSectionTitleIndex(
    tableScrollAmount: tableScrollAmount,
    rowHeights: rowHeights,
    sectionTitlePositions: sectionTitlePositions,
  );
  final pinnedSectionHeight = rowHeights[pinnedSectionIndex];

  // TODO

  return -1;
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
