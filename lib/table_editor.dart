import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:goloc_editor/document_bloc.dart';
import 'package:goloc_editor/table_size_bloc.dart';
import 'package:goloc_editor/util/bloc.dart';
import 'package:goloc_editor/util/widget_util.dart';
import 'package:goloc_editor/widget/value_stream_builder.dart';
import 'package:provider/provider.dart';

const double _cellWidth = 128;
const _padding = const EdgeInsets.all(8.0);

class _TableOffset extends ValueNotifier<double> {
  _TableOffset() : super(0);
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
      child: Consumer<DocumentBloc>(
        builder: (context, bloc, _) => ValueStreamBuilder<DocumentSize>(
          stream: bloc.size,
          initialValue: DocumentSize.empty,
          builder: (context, size) {
            if (size.rows == 0) {
              return Container();
            }
            return BlocProvider(
              builder: (context) => TableSizeBloc(
                data: DocumentBloc.of(context).data,
                cellWidth: _cellWidth,
                style:
                    inherited<DefaultTextStyle>(context, listen: false).style,
                textScaleFactor: inherited<MediaQuery>(context, listen: false)
                    .data
                    .textScaleFactor,
                padding: _padding,
              ),
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(0),
                  child: Container(
                    color: Colors.black12,
                    child: SafeArea(child: SizedBox.shrink()),
                  ),
                ),
                body: Column(
                  children: <Widget>[
                    Material(
                      color: Theme.of(context).appBarTheme.color,
                      elevation: 4,
                      child: _Row(i: 0),
                    ),
                    Expanded(
                      child: ListView.separated(
                        addAutomaticKeepAlives: true,
                        itemCount: max(0, size.rows - 1),
                        itemBuilder: (_, i) => _Row(i: i + 1),
                        separatorBuilder: (_, __) => Divider(height: 1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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

class _RowState extends State<_Row> with AutomaticKeepAliveClientMixin {
  ScrollController _ctrl;
  _TableOffset _tableOffset;

  @override
  void initState() {
    super.initState();
    _tableOffset = Provider.of<_TableOffset>(context, listen: false);
    _tableOffset.addListener(_updateWithOffset);
    _ctrl = ScrollController(
        initialScrollOffset: _tableOffset.value, keepScrollOffset: false);
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
    super.build(context);
    return ValueStreamBuilder<double>(
      stream: TableSizeBloc.of(context).getRowHeight(widget.i),
      initialValue: TableSizeBloc.of(context).getCurrentRowHeight(widget.i),
      builder: (context, height) => Container(
        height: height,
        color: widget.i % 2 == 1 ? Colors.transparent : Colors.black12,
        child: ValueStreamBuilder<int>(
          stream: DocumentBloc.of(context).cols,
          initialValue: 0,
          builder: (context, cols) => ListView.separated(
            controller: _ctrl,
            itemCount: cols,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, j) => _Cell(row: widget.i, col: j),
            separatorBuilder: (_, __) => const VerticalDivider(width: 1),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => false;
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

  @override
  void initState() {
    super.initState();
    _ctrl.text =
        DocumentBloc.of(context).getCurrentCellValue(widget.row, widget.col);
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
        style: DefaultTextStyle.of(context).style,
        maxLines: null,
        onChanged: (text) {
          DocumentBloc.of(context).setCell(widget.row, widget.col, text);
          TableSizeBloc.of(context)
              .notifyCellTextChanged(widget.row, widget.col, text);
        },
      ),
    );
  }
}
