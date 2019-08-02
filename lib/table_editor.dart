import 'package:flutter/material.dart';

const double _cellHeight = 56;
const double _cellWidth = 128;

class TableEditor extends StatefulWidget {
  @override
  _TableEditorState createState() => _TableEditorState();
}

class _TableEditorState extends State<TableEditor> {
  final _offsetNotifier = ValueNotifier<double>(0);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 500,
      itemBuilder: (context, i) => _Row(i: i, offsetNotifier: _offsetNotifier),
      shrinkWrap: true,
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
      child: ListView.builder(
        controller: _ctrl,
        itemCount: 50,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, j) => SizedBox(
          width: _cellWidth,
          child: Text('Cell(${widget.i}, $j)'),
        ),
      ),
    );
  }
}
