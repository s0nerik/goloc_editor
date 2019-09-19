import 'package:flutter_test/flutter_test.dart';
import 'package:goloc_editor/table/src/util.dart';
import 'package:meta/meta.dart';

@immutable
class _OverlapTest {
  final String name;
  final double draggableY;
  final double draggableHeight;
  final double tableScrollAmount;
  final List<double> rowHeights;
  final List<int> expectedOverlapIndices;

  _OverlapTest({
    @required this.name,
    @required this.draggableY,
    @required this.draggableHeight,
    @required this.tableScrollAmount,
    @required this.rowHeights,
    @required this.expectedOverlapIndices,
  });
}

@immutable
class _PinnedSectionTitleIndexTest {
  final String name;
  final double tableScrollAmount;
  final List<double> rowHeights;
  final List<int> sectionTitlePositions;
  final int expectedResult;

  _PinnedSectionTitleIndexTest({
    @required this.name,
    @required this.tableScrollAmount,
    @required this.rowHeights,
    @required this.sectionTitlePositions,
    @required this.expectedResult,
  });
}

final _overlapTests = <_OverlapTest>[
  _OverlapTest(
    name: 'single 1',
    draggableY: 20,
    draggableHeight: 9,
    tableScrollAmount: 0,
    rowHeights: [10, 10, 10, 10, 10, 10],
    expectedOverlapIndices: [2],
  ),
  _OverlapTest(
    name: 'single 2 (edge value)',
    draggableY: 20,
    draggableHeight: 10,
    tableScrollAmount: 0,
    rowHeights: [10, 10, 10, 10, 10, 10],
    expectedOverlapIndices: [2],
  ),
  _OverlapTest(
    name: 'multiple 1',
    draggableY: 20,
    draggableHeight: 11,
    tableScrollAmount: 0,
    rowHeights: [10, 10, 10, 10, 10, 10],
    expectedOverlapIndices: [2, 3],
  ),
  _OverlapTest(
    name: 'multiple 2 (edge value)',
    draggableY: 20,
    draggableHeight: 20,
    tableScrollAmount: 0,
    rowHeights: [10, 10, 10, 10, 10, 10],
    expectedOverlapIndices: [2, 3],
  ),
];

final _pinnedSectionTitleIndexTests = [
  _PinnedSectionTitleIndexTest(
    name: 'missing',
    tableScrollAmount: 0,
    rowHeights: [10, 10, 10],
    sectionTitlePositions: [],
    expectedResult: -1,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'simple',
    tableScrollAmount: 0,
    rowHeights: [10, 10, 10],
    sectionTitlePositions: [0],
    expectedResult: 0,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'simple 2',
    tableScrollAmount: 10,
    rowHeights: [10, 10, 10],
    sectionTitlePositions: [0],
    expectedResult: 0,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'simple 3',
    tableScrollAmount: 10,
    rowHeights: [10, 10, 10],
    sectionTitlePositions: [1],
    expectedResult: 1,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'no pinned title',
    tableScrollAmount: 0,
    rowHeights: [10, 10, 10],
    sectionTitlePositions: [1],
    expectedResult: -1,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'different heights 1',
    tableScrollAmount: 23,
    rowHeights: [22, 10, 10],
    sectionTitlePositions: [1],
    expectedResult: 1,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'different heights 2',
    tableScrollAmount: 9,
    rowHeights: [10, 15, 20, 10, 25],
    sectionTitlePositions: [1, 3],
    expectedResult: -1,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'different heights 3',
    tableScrollAmount: 11,
    rowHeights: [10, 15, 20, 10, 25],
    sectionTitlePositions: [1, 3],
    expectedResult: 1,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'different heights 4',
    tableScrollAmount: 26,
    rowHeights: [10, 15, 20, 10, 25],
    sectionTitlePositions: [1, 3],
    expectedResult: 1,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'different heights 5',
    tableScrollAmount: 56,
    rowHeights: [10, 15, 20, 10, 25],
    sectionTitlePositions: [1, 3],
    expectedResult: 3,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'consecutive titles 1',
    tableScrollAmount: 19,
    rowHeights: [10, 10, 10, 10, 10],
    sectionTitlePositions: [2, 3],
    expectedResult: -1,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'consecutive titles 2',
    tableScrollAmount: 21,
    rowHeights: [10, 10, 10, 10, 10],
    sectionTitlePositions: [2, 3],
    expectedResult: 2,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'consecutive titles 3',
    tableScrollAmount: 29,
    rowHeights: [10, 10, 10, 10, 10],
    sectionTitlePositions: [2, 3],
    expectedResult: 2,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'consecutive titles 4',
    tableScrollAmount: 30,
    rowHeights: [10, 10, 10, 10, 10],
    sectionTitlePositions: [2, 3],
    expectedResult: 3,
  ),
  _PinnedSectionTitleIndexTest(
    name: 'consecutive titles 5',
    tableScrollAmount: 31,
    rowHeights: [10, 10, 10, 10, 10],
    sectionTitlePositions: [2, 3],
    expectedResult: 3,
  ),
];

void main() {
  for (final t in _overlapTests) {
    test('overlap: ${t.name}', () {
      final result = overlap(
        draggableY: t.draggableY,
        draggableHeight: t.draggableHeight,
        tableScrollAmount: t.tableScrollAmount,
        rowHeights: t.rowHeights,
      );
      expect(result.map((o) => o.index).toList(), t.expectedOverlapIndices);
    });
  }
  for (final t in _pinnedSectionTitleIndexTests) {
    test('pinnedSectionTitleIndex: ${t.name}', () {
      final result = pinnedSectionTitleIndex(
        tableScrollAmount: t.tableScrollAmount,
        rowHeights: t.rowHeights,
        sectionTitlePositions: t.sectionTitlePositions,
      );
      expect(result, t.expectedResult);
    });
  }
}
