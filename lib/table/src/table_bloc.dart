import 'dart:async';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:goloc_editor/table/src/util.dart';
import 'package:goloc_editor/util/bloc.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class TableBloc implements Bloc {
  final TextStyle style;
  final double textScaleFactor;
  final EdgeInsetsGeometry padding;
  final double cellWidth;

  final _sizes = BehaviorSubject<List<List<double>>>();

  final draggedRow = BehaviorSubject.seeded(-1);
  final dragOffset = BehaviorSubject.seeded(Offset.zero);
  final overlappedRows = BehaviorSubject<List<Overlap>>.seeded(const []);
  final horizontalOffset = BehaviorSubject<double>.seeded(0);
  final verticalOffset = BehaviorSubject<double>.seeded(0);

  Stream<double> rowHeightStream(int row) =>
      _sizes.map((sizes) => sizes[row]).map(_getRowHeight).distinct();

  double rowHeight(int row) => _getRowHeight(_sizes.value[row]);

  List<double> get _rowHeights => _sizes.value.map(_getRowHeight).toList();

  double _getRowHeight(List<double> cellHeights) {
    if (cellHeights.isNotEmpty) {
      return cellHeights.reduce(max);
    } else {
      return 0;
    }
  }

  int rowIndexByOffset(double offset) {
    double tmpOffset = 0;
    throw UnimplementedError();
  }

  TableBloc({
    @required List<List<String>> data,
    @required this.style,
    @required this.textScaleFactor,
    @required this.padding,
    @required this.cellWidth,
  }) {
    _sizes.value = data.map((row) {
      return row
          .map((cellText) => _getTextHeight(
              cellText, style, textScaleFactor, padding, cellWidth))
          .toList();
    }).toList();
  }

  void notifyDragStarted(int row) {
    draggedRow.value = row;
  }

  void notifyDragOffsetChanged(Offset offset) {
    dragOffset.value = offset;
    overlappedRows.value = overlap(
      draggableY: offset.dy,
      draggableHeight: rowHeight(draggedRow.value),
      tableScrollAmount: verticalOffset.value + rowHeight(0),
      rowHeights: _rowHeights,
    );
  }

  void notifyDragEnded() {
    dragOffset.value = Offset.zero;
    draggedRow.value = -1;
    overlappedRows.value = const [];
  }

  void notifyCellTextChanged(int row, int col, String text) {
    final list = _sizes.value;
    list[row][col] =
        _getTextHeight(text, style, textScaleFactor, padding, cellWidth);
    _sizes.value = list;
  }

  @override
  void dispose() {
    _sizes.close();
  }

  static TableBloc of(BuildContext context) =>
      Provider.of<TableBloc>(context, listen: false);
}

double _getTextHeight(String text, TextStyle style, double textScaleFactor,
    EdgeInsetsGeometry padding, double cellWidth) {
  final width = cellWidth - padding.horizontal;
  final constraints = BoxConstraints(
    maxWidth: width,
    minHeight: 0.0,
    minWidth: 0.0,
  );

  RenderParagraph renderParagraph = RenderParagraph(
    TextSpan(
      text: text,
      style: style,
    ),
    textDirection: TextDirection.ltr,
    textScaleFactor: textScaleFactor,
  );
  renderParagraph.layout(constraints);
  double result = renderParagraph.getMinIntrinsicHeight(width).ceilToDouble();
  return result + padding.vertical;
}
