import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:goloc_editor/bloc.dart';
import 'package:goloc_editor/document_bloc.dart';
import 'package:goloc_editor/value_stream_builder.dart';
import 'package:goloc_editor/widget_util.dart';
import 'package:provider/provider.dart';

const double _cellWidth = 128;

class _TableOffset extends ValueNotifier<double> {
  _TableOffset() : super(0);
}

class _RowHeight extends ChangeNotifier implements ValueListenable<double> {
  final Map<int, double> _cells = {};

  @override
  double get value {
    final heights = _cells.values;
    if (heights.isNotEmpty) {
      return heights.reduce(max);
    } else {
      return 0;
    }
  }

  double getCellHeight(int cell) => _cells[cell];

  void setCellHeight(int cell, double height) {
    final oldValue = value;
    _cells[cell] = height;
    final newValue = value;
    if (newValue != oldValue) {
      notifyListeners();
    }
  }
}

class TableEditor extends StatefulWidget {
  final String source;

  const TableEditor({
    Key key,
    @required this.source,
  }) : super(key: key);

  @override
  _TableEditorState createState() => _TableEditorState();
}

class _TableEditorState extends State<TableEditor> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(builder: (_) => DocumentBloc(widget.source)),
        ChangeNotifierProvider(builder: (_) => _TableOffset()),
      ],
      // TODO: handle empty document
      child: Consumer<DocumentBloc>(
        builder: (context, bloc, _) => ValueStreamBuilder<int>(
          stream: bloc.rows,
          initialValue: 0,
          builder: (context, rows) => Column(
            children: <Widget>[
              Material(
                elevation: 4,
                child: _Row(i: 0),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: max(0, rows - 1),
                  itemBuilder: (_, i) => _Row(i: i + 1),
                  separatorBuilder: (_, __) =>
                      Container(height: 1, color: Colors.black12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatefulWidget {
  final int i;

  const _Row({
    Key key,
    @required this.i,
  }) : super(key: key);

  @override
  _RowState createState() => _RowState();
}

class _RowState extends State<_Row> {
  final ScrollController _ctrl = ScrollController();
  _TableOffset _tableOffset;

  @override
  void initState() {
    super.initState();
    _tableOffset = Provider.of<_TableOffset>(context, listen: false);
    _tableOffset.addListener(_updateWithOffset);
    _ctrl.addListener(_notifyOffset);
  }

  @override
  void dispose() {
    _tableOffset.removeListener(_updateWithOffset);
    _ctrl.removeListener(_notifyOffset);
    super.dispose();
  }

  void _updateWithOffset() {
    if (_ctrl.offset != _tableOffset.value) {
      _ctrl.jumpTo(_tableOffset.value);
    }
  }

  void _notifyOffset() {
    _tableOffset.value = _ctrl.offset;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (_) => _RowHeight(),
      child: Consumer<_RowHeight>(
        builder: (context, height, child) {
          return Container(
            height: height.value,
            color: widget.i % 2 == 1 ? Colors.transparent : Colors.black12,
            child: child,
          );
        },
        child: ValueStreamBuilder<int>(
          stream: DocumentBloc.of(context).cols,
          initialValue: 0,
          builder: (context, cols) => ListView.separated(
            controller: _ctrl,
            itemCount: cols,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, j) => _Cell(row: widget.i, col: j),
            separatorBuilder: (_, __) =>
                Container(width: 1, color: Colors.black12),
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatefulWidget {
  final int row;
  final int col;

  const _Cell({
    Key key,
    @required this.row,
    @required this.col,
  }) : super(key: key);

  @override
  _CellState createState() => _CellState();
}

class _CellState extends State<_Cell> {
  final _ctrl = TextEditingController();

  static const _padding = const EdgeInsets.all(8.0);

  _RowHeight _rowHeight;
  TextStyle _style;

  @override
  void initState() {
    super.initState();
    _rowHeight = provided<_RowHeight>(context, listen: false);
    _style = inherited<DefaultTextStyle>(context, listen: false).style;
    _ctrl.text =
        DocumentBloc.of(context).getCurrentCellValue(widget.row, widget.col);
    _updateCellHeight();
  }

  void _updateCellHeight() {
    final height = _getTextHeight(context, _ctrl.text, _style, _padding);
    scheduleMicrotask(() {
      _rowHeight.setCellHeight(widget.col, height);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _cellWidth,
      child: TextField(
        controller: _ctrl,
        expands: true,
        decoration: InputDecoration(
          contentPadding: _padding,
          border: InputBorder.none,
        ),
        style: _style,
        maxLines: null,
        onChanged: (text) {
          DocumentBloc.of(context).setCell(widget.row, widget.col, text);
          _updateCellHeight();
        },
      ),
    );
  }

  double _getTextHeight(BuildContext context, String text, TextStyle style,
      EdgeInsetsGeometry padding) {
    final width = _cellWidth - padding.horizontal;
    final constraints = BoxConstraints(
      maxWidth: width,
      minHeight: 0.0,
      minWidth: 0.0,
    );

    final scale =
        inherited<MediaQuery>(context, listen: false).data.textScaleFactor;
    RenderParagraph renderParagraph = RenderParagraph(
      TextSpan(
        text: text,
        style: style,
      ),
      textDirection: TextDirection.ltr,
      textScaleFactor: scale,
    );
    renderParagraph.layout(constraints);
    double result = renderParagraph.getMinIntrinsicHeight(width).ceilToDouble();
    return result + padding.vertical;
  }
}
