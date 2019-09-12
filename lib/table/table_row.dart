import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goloc_editor/document_bloc.dart';
import 'package:goloc_editor/table/data.dart';
import 'package:goloc_editor/table/drag_handle.dart';
import 'package:goloc_editor/table/table_bloc.dart';
import 'package:goloc_editor/table/table_cell.dart';
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
  TableHorizontalPosition _tableOffset;

  StreamSubscription _heightSub;
  StreamSubscription _colsSub;

  @override
  void initState() {
    super.initState();
    _tableOffset = TableHorizontalPosition.of(context);
    _tableOffset.addListener(_updateWithOffset);
    _ctrl = ScrollController(
        initialScrollOffset: _tableOffset.value, keepScrollOffset: false);
    _ctrl.addListener(_notifyOffset);

    _heightSub = TableBloc.of(context).rowHeightStream(widget.i).listen((_) {
      setState(() {});
    });
    _colsSub = DocumentBloc.of(context).colsStream.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tableOffset.removeListener(_updateWithOffset);
    _ctrl.removeListener(_notifyOffset);
    _heightSub?.cancel();
    _colsSub?.cancel();
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
          final result = key != candidateKey;
          if (result) {
            DropTargets.of(context).add(widget.i);
          }
          return result;
        },
        onLeave: (candidateKey) {
          DropTargets.of(context).remove(widget.i);
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
    onDragStarted: () {
//      DropTarget.of(context).setKey(scrollViewKey.currentContext, null);
//      DraggedRow.of(context).value = key.value;
    },
    onDragPositionChanged: (details) {
      DragPosition.of(context).value = details.offset;
    },
    onDragEnd: (_) {
      DragPosition.of(context).value = Offset.zero;
//      DraggedRow.of(context).value = null;
    },
//    childWhenDragging: SizedBox.shrink(),
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
    final candidateHeight = widget.candidateIndex != null
        ? TableBloc.of(context).rowHeight(widget.candidateIndex)
        : 0.0;

    return AnimatedSize(
      duration: duration,
      vsync: VsyncProvider.of(context),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
//          TableSizeBloc.of(context)
//                  .DropTargets
//                  .of(context)
//                  .isLast(widget.contentKey.value)
//              ? SizedBox(height: candidateHeight)
//              : const SizedBox.shrink(),
          widget.child,
        ],
      ),
    );
  }
}
