import 'dart:async';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:goloc_editor/bloc.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';

class TableSizeBloc implements Bloc {
  final TextStyle style;
  final double textScaleFactor;
  final EdgeInsetsGeometry padding;
  final double cellWidth;

  final _sizes = BehaviorSubject<List<List<double>>>();

  Stream<double> getRowHeight(int row) =>
      _sizes.map((sizes) => sizes[row]).map(_getRowHeight).distinct();

  double getCurrentRowHeight(int row) => _getRowHeight(_sizes.value[row]);

  double _getRowHeight(List<double> cellHeights) {
    if (cellHeights.isNotEmpty) {
      return cellHeights.reduce(max);
    } else {
      return 0;
    }
  }

  TableSizeBloc({
    @required List<List<String>> data,
    @required this.style,
    @required this.textScaleFactor,
    @required this.padding,
    @required this.cellWidth,
  }) {
    print('TableSizeBloc: start');
    _sizes.value = data.map((row) {
      print('TableSizeBloc: map row');
      return row
          .map((cellText) => _getTextHeight(
              cellText, style, textScaleFactor, padding, cellWidth))
          .toList();
    }).toList();
    print('TableSizeBloc: done');
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

  static TableSizeBloc of(BuildContext context) =>
      Provider.of<TableSizeBloc>(context, listen: false);
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
