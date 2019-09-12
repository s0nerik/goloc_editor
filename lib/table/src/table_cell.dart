import 'package:flutter/material.dart';
import 'package:goloc_editor/document_bloc.dart';
import 'package:goloc_editor/table/src/data.dart';
import 'package:goloc_editor/table/src/table_bloc.dart';

class TCell extends StatefulWidget {
  final int row;
  final int col;

  const TCell({
    Key key,
    @required this.row,
    @required this.col,
  }) : super(key: key);

  @override
  _TCellState createState() => _TCellState();
}

class _TCellState extends State<TCell> {
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
      width: cellWidth,
      child: TextField(
        controller: _ctrl,
        expands: true,
        decoration: const InputDecoration(
          contentPadding: padding,
          border: InputBorder.none,
        ),
        style: DefaultTextStyle.of(context).style,
        maxLines: null,
        onChanged: (text) {
          DocumentBloc.of(context).setCell(widget.row, widget.col, text);
          TableBloc.of(context)
              .notifyCellTextChanged(widget.row, widget.col, text);
        },
      ),
    );
  }
}
