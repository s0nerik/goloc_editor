import 'package:flutter_test/flutter_test.dart';
import 'package:goloc_editor/table/src/util.dart';
import 'package:meta/meta.dart';

@immutable
class _OverlapIndexTest {
  final String name;
  final double draggableY;
  final double draggableHeight;
  final double tableScrollAmount;
  final List<double> rowOffsets;
  final List<double> rowHeights;
  final List<int> sectionTitlePositions;
  final int expectedResult;

  _OverlapIndexTest({
    @required this.name,
    @required this.draggableY,
    @required this.draggableHeight,
    @required this.tableScrollAmount,
    @required this.rowOffsets,
    @required this.rowHeights,
    @required this.sectionTitlePositions,
    @required this.expectedResult,
  });
}

@immutable
class _PinnedSectionTitleIndexTest {
  final String name;
  final double tableScrollAmount;
  final List<double> rowOffsets;
  final List<double> rowHeights;
  final List<int> sectionTitlePositions;
  final int expectedResult;

  _PinnedSectionTitleIndexTest({
    @required this.name,
    @required this.tableScrollAmount,
    @required this.rowOffsets,
    @required this.rowHeights,
    @required this.sectionTitlePositions,
    @required this.expectedResult,
  });
}

final _overlapIndexTests = [
//  _OverlapIndexTest(
//    name: '1',
//    draggableY: 20,
//    draggableHeight: 10,
//    tableScrollAmount: 10,
//    rowOffsets: [0, 10, 20, 30, 40, 50],
//    rowHeights: [10, 10, 10, 10, 10, 10],
//    sectionTitlePositions: [],
//    expectedResult: -1,
//  ),
//  _OverlapIndexTest(
//    name: 'simple',
//    draggableY: 0,
//    draggableHeight: 10,
//    tableScrollAmount: 10,
//    rowOffsets: [0, 10, 20, 30, 40, 50],
//    rowHeights: [10, 10, 10, 10, 10, 10],
//    sectionTitlePositions: [],
//    expectedResult: 0,
//  )
];

final _pinnedSectionTitleIndexTests = [
  _PinnedSectionTitleIndexTest(
    name: 'missing',
    tableScrollAmount: 0,
    rowOffsets: [0, 10, 20],
    rowHeights: [10, 10, 10],
    sectionTitlePositions: [],
    expectedResult: -1,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'simple',
    tableScrollAmount: 0,
    rowOffsets: [0, 10, 20],
    rowHeights: [10, 10, 10],
    sectionTitlePositions: [1],
    expectedResult: 1,
  ),
];

void main() {
  for (final t in _overlapIndexTests) {
    test('overlapIndex: ${t.name}', () {
      final result = overlapIndex(
        draggableY: t.draggableY,
        draggableHeight: t.draggableHeight,
        tableScrollAmount: t.tableScrollAmount,
        rowOffsets: t.rowOffsets,
        rowHeights: t.rowHeights,
        sectionTitlePositions: t.sectionTitlePositions,
      );
      expect(result, t.expectedResult);
    });
  }
  for (final t in _pinnedSectionTitleIndexTests) {
    test('pinnedSectionTitleIndex: ${t.name}', () {
      final result = pinnedSectionTitleIndex(
        tableScrollAmount: t.tableScrollAmount,
        rowOffsets: t.rowOffsets,
        rowHeights: t.rowHeights,
        sectionTitlePositions: t.sectionTitlePositions,
      );
      expect(result, t.expectedResult);
    });
  }
}
