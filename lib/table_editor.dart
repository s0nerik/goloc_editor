import 'dart:math';

import 'package:flutter/material.dart';
import 'package:goloc_editor/document_bloc.dart';
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
      child: Consumer<DocumentBloc>(builder: (context, bloc, _) {
        // TODO: handle empty document
        return StreamBuilder<int>(
          stream: bloc.rows,
          initialData: 0,
          builder: (context, snapshot) {
            return Column(
              children: <Widget>[
                _Row(i: 0, offsetNotifier: _offsetNotifier),
                Expanded(
                  child: ListView.builder(
                    itemCount: max(0, snapshot.data - 1),
                    itemBuilder: (context, i) =>
                        _Row(i: i + 1, offsetNotifier: _offsetNotifier),
                  ),
                ),
              ],
            );
          },
        );
      }),
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
      child: StreamBuilder<int>(
        stream: DocumentBloc.of(context).cols,
        initialData: 0,
        builder: (context, snapshot) {
          return ListView.builder(
            controller: _ctrl,
            itemCount: snapshot.data,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, j) => _Cell(row: widget.i, col: j),
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
    return StreamBuilder<String>(
      stream: DocumentBloc.of(context).getCell(row, col),
      initialData: '',
      builder: (context, snapshot) {
        return SizedBox(
          width: _cellWidth,
          child: Text(snapshot.data),
        );
      },
    );
  }
}
