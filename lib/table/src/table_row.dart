import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goloc_editor/document_bloc.dart';
import 'package:goloc_editor/table/src/drag_handle.dart';
import 'package:goloc_editor/table/src/table_bloc.dart';
import 'package:goloc_editor/table/src/table_cell.dart';
import 'package:goloc_editor/table/src/util.dart';
import 'package:goloc_editor/widget/async.dart';
import 'package:goloc_editor/widget/drag_target.dart' as drag;
import 'package:vsync_provider/vsync_provider.dart';

class TRow extends StatefulWidget {
  final int i;

  const TRow({
    Key key,
    @required this.i,
  }) : super(key: key);

  @override
  _TRowState createState() => _TRowState();
}

class _TRowState extends State<TRow> with TickerProviderStateMixin {
  ScrollController _ctrl;

  TableBloc _tableBloc;

  StreamSubscription _horizontalOffsetSub;
  StreamSubscription _heightSub;
  StreamSubscription _colsSub;

  @override
  void initState() {
    super.initState();
    _tableBloc = TableBloc.of(context);

    _ctrl = ScrollController(
      initialScrollOffset: _tableBloc.horizontalOffset.value,
      keepScrollOffset: false,
    );
    _ctrl.addListener(_notifyOffset);

    _horizontalOffsetSub =
        _tableBloc.horizontalOffset.listen(_updateWithOffset);
    _heightSub = TableBloc.of(context).rowHeightStream(widget.i).listen((_) {
      setState(() {});
    });
    _colsSub = DocumentBloc.of(context).colsStream.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_notifyOffset);
    _horizontalOffsetSub?.cancel();
    _heightSub?.cancel();
    _colsSub?.cancel();
    super.dispose();
  }

  void _updateWithOffset(double offset) {
    if (_ctrl.offset != offset) {
      _ctrl.jumpTo(offset);
    }
  }

  void _notifyOffset() {
    _tableBloc.horizontalOffset.value = _ctrl.offset;
  }

  @override
  Widget build(BuildContext context) {
    final height = TableBloc.of(context).rowHeight(widget.i);
    final cols = DocumentBloc.of(context).cols;

    final key = ValueKey(widget.i);

    final content = _buildContent(context, key, height, _ctrl, cols);

    final draggable = _buildDraggable(context, key, content, height);

    return VsyncProvider(
      isSingleTicker: false,
      child: drag.DragTarget<Key>(
        key: key,
        onWillAccept: (candidateKey) {
          print('onWillAccept[${key.value}]: $candidateKey');
          return key != candidateKey;
        },
        onAccept: (row) {
          print('onAccept[${key.value}]: $row');
        },
        builder: (BuildContext context, List<Key> candidateData, _) =>
            _buildDragTarget(context, candidateData, draggable, content, key),
      ),
    );
  }
}

Widget _buildContent(BuildContext context, ValueKey<int> key, double height,
    ScrollController ctrl, int cols) {
  return Container(
    key: key,
    color: key.value % 2 == 1 ? Colors.transparent : Colors.black12,
    child: SizedBox(
      height: height,
      child: Row(
        children: <Widget>[
          DragHandle(row: key.value),
          const VerticalDivider(width: 1),
          Expanded(
            child: ListView.separated(
              controller: ctrl,
              itemCount: cols,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, j) => TCell(row: key.value, col: j),
              separatorBuilder: (_, __) => const VerticalDivider(width: 1),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDraggable(
    BuildContext context, ValueKey<int> key, Widget content, double height) {
  return drag.LongPressDraggable<Key>(
    data: key,
    axis: Axis.vertical,
    onDragStarted: () => TableBloc.of(context).notifyDragStarted(key.value),
    onDragPositionChanged: (details) {
      details.offset.translate(0, -MediaQuery.of(context).viewInsets.top);
      TableBloc.of(context).notifyDragOffsetChanged(details.offset);
    },
    onDragEnd: (_) => TableBloc.of(context).notifyDragEnded(),
    maxSimultaneousDrags: 1,
    feedback: Material(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: content,
      ),
      elevation: 4.0,
    ),
    child: content,
  );
}

Widget _buildDragTarget(BuildContext context, List<Key> candidateData,
    Widget draggable, Widget content, ValueKey<int> key) {
  return _DragTarget(
    contentKey: key,
    candidateIndex: candidateData.isNotEmpty
        ? (candidateData[0] as ValueKey<int>).value
        : null,
    child: candidateData.isNotEmpty ? content : draggable,
  );
}

class _DragTarget extends StatefulWidget {
  final ValueKey<int> contentKey;
  final int candidateIndex;
  final Widget child;

  const _DragTarget({
    Key key,
    @required this.contentKey,
    @required this.candidateIndex,
    @required this.child,
  }) : super(key: key);

  @override
  _DragTargetState createState() => _DragTargetState();
}

class _DragTargetState extends State<_DragTarget> {
  static const duration = Duration(milliseconds: 100);

  @override
  Widget build(BuildContext context) {
    return ValueObservableBuilder<List<Overlap>>(
      stream: TableBloc.of(context).overlappedRows,
      builder: (context, overlappedRows) {
        final isOverlapped = !overlappedRows
            .indexWhere((o) => o.index == widget.contentKey.value)
            .isNegative;

        return Container(
          decoration: BoxDecoration(
            color: isOverlapped ? Colors.pink.withAlpha(122) : Colors.white,
          ),
          child: widget.child,
        );
      },
    );
  }
}
