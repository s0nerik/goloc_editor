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
    rowOffsets: rowOffsets,
    rowHeights: rowHeights,
    sectionTitlePositions: sectionTitlePositions,
  );
  final pinnedSectionHeight = rowHeights[pinnedSectionIndex];

  // TODO

  return -1;
}

int pinnedSectionTitleIndex({
  @required double tableScrollAmount,
  @required List<double> rowOffsets,
  @required List<double> rowHeights,
  @required List<int> sectionTitlePositions,
}) {
  assert(rowOffsets.length == rowHeights.length);
  if (rowOffsets.isEmpty || sectionTitlePositions.isEmpty) {
    return -1;
  }

  // TODO

  return -1;
}
