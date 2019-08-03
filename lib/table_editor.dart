import 'dart:math';

import 'package:flutter/material.dart';
import 'package:goloc_editor/document_bloc.dart';
import 'package:goloc_editor/value_stream_builder.dart';
import 'package:provider/provider.dart';

const double _cellHeight = 56;
const double _cellWidth = 128;

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
  final _offsetNotifier = ValueNotifier<double>(0);

  @override
  Widget build(BuildContext context) {
    return Provider(
      builder: (context) => DocumentBloc(widget.source),
      // TODO: handle empty document
      child: Consumer<DocumentBloc>(
        builder: (context, bloc, _) => ValueStreamBuilder<int>(
          stream: bloc.rows,
          initialValue: 0,
          builder: (context, rows) => Column(
            children: <Widget>[
              _Row(i: 0, offsetNotifier: _offsetNotifier),
              Expanded(
                child: ListView.separated(
                  itemCount: max(0, rows - 1),
                  itemBuilder: (_, i) =>
                      _Row(i: i + 1, offsetNotifier: _offsetNotifier),
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
  final ValueNotifier<double> offsetNotifier;

  const _Row({
    Key key,
    @required this.i,
    @required this.offsetNotifier,
  }) : super(key: key);

  @override
  _RowState createState() => _RowState();
}

class _RowState extends State<_Row> {
  final ScrollController _ctrl = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.offsetNotifier.addListener(_updateWithOffset);
    _ctrl.addListener(_notifyOffset);
  }

  @override
  void dispose() {
    widget.offsetNotifier.removeListener(_updateWithOffset);
    _ctrl.removeListener(_notifyOffset);
    super.dispose();
  }

  void _updateWithOffset() {
    if (_ctrl.offset != widget.offsetNotifier.value) {
      _ctrl.jumpTo(widget.offsetNotifier.value);
    }
  }

  void _notifyOffset() {
    widget.offsetNotifier.value = _ctrl.offset;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _cellHeight,
      child: ValueStreamBuilder<int>(
        stream: DocumentBloc.of(context).cols,
        initialValue: 0,
        builder: (context, cols) {
          return ListView.separated(
            controller: _ctrl,
            itemCount: cols,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, j) => _Cell(row: widget.i, col: j),
            separatorBuilder: (_, __) =>
                Container(width: 1, color: Colors.black12),
          );
        },
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final int row;
  final int col;

  const _Cell({
    Key key,
    @required this.row,
    @required this.col,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueStreamBuilder<String>(
      stream: DocumentBloc.of(context).getCell(row, col),
      initialValue: '',
      builder: (context, value) {
        return SizedBox(
          width: _cellWidth,
          child: Text(value),
        );
      },
    );
  }
}
