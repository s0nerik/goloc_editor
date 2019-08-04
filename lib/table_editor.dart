import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:goloc_editor/bloc.dart';
import 'package:goloc_editor/document_bloc.dart';
import 'package:goloc_editor/value_stream_builder.dart';
import 'package:provider/provider.dart';

const double _cellHeight = 56;
const double _cellWidth = 128;

class _TableOffsetNotifier extends ValueNotifier<double> {
  _TableOffsetNotifier() : super(0);
}

class _RowHeight extends ChangeNotifier implements ValueListenable<double> {
  final double _defaultHeight;
  final Map<int, double> _cells = {};

  _RowHeight({double initialHeight = _cellHeight})
      : _defaultHeight = initialHeight;

  @override
  double get value {
    final heights = _cells.values;
    if (heights.isNotEmpty) {
      return heights.reduce(max);
    } else {
      return _defaultHeight;
    }
  }

  void setCellHeight(int cell, double height) {
    _cells[cell] = height;
    final oldValue = value;
    if (height != oldValue) {
      notifyListeners();
    }
  }

  static _RowHeight of(BuildContext context) =>
      Provider.of<_RowHeight>(context);
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
        ChangeNotifierProvider(builder: (_) => _TableOffsetNotifier()),
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
  _TableOffsetNotifier _offsetNotifier;

  @override
  void initState() {
    super.initState();
    _offsetNotifier = Provider.of<_TableOffsetNotifier>(context, listen: false);
    _offsetNotifier.addListener(_updateWithOffset);
    _ctrl.addListener(_notifyOffset);
  }

  @override
  void dispose() {
    _offsetNotifier.removeListener(_updateWithOffset);
    _ctrl.removeListener(_notifyOffset);
    super.dispose();
  }

  void _updateWithOffset() {
    if (_ctrl.offset != _offsetNotifier.value) {
      _ctrl.jumpTo(_offsetNotifier.value);
    }
  }

  void _notifyOffset() {
    _offsetNotifier.value = _ctrl.offset;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (_) => _RowHeight(),
      child: Consumer<_RowHeight>(
        builder: (context, height, _) => Container(
          height: height.value,
          color: widget.i % 2 == 1 ? Colors.transparent : Colors.black12,
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
  final _ctrl = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    DocumentBloc.of(context)
        .getCell(widget.row, widget.col)
        .first
        .then((value) {
      _ctrl.text = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;
    const padding = const EdgeInsets.all(8.0);
    return SizedBox(
      width: _cellWidth,
      child: TextField(
        controller: _ctrl,
        expands: true,
        decoration: InputDecoration(
          contentPadding: padding,
          border: InputBorder.none,
        ),
        style: style,
        maxLines: null,
        onChanged: (text) {
          DocumentBloc.of(context).setCell(widget.row, widget.col, text);
          _RowHeight.of(context).setCellHeight(
              widget.col, _getTextHeight(context, text, style, padding));
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

    final scale = MediaQuery.of(context).textScaleFactor;
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
