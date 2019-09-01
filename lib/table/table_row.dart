import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goloc_editor/document_bloc.dart';
import 'package:goloc_editor/table/data.dart';
import 'package:goloc_editor/table/drag_handle.dart';
import 'package:goloc_editor/table/table_cell.dart';
import 'package:goloc_editor/table_size_bloc.dart';
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

    _heightSub =
        TableSizeBloc.of(context).rowHeightStream(widget.i).listen((_) {
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
    final height = TableSizeBloc.of(context).rowHeight(widget.i);
    final cols = DocumentBloc.of(context).cols;

    final key = ValueKey(widget.i);
    print('build: ${widget.i}');

    final content = Container(
      key: key,
      color: widget.i % 2 == 1 ? Colors.transparent : Colors.black12,
      child: SizedBox(
        height: height,
        child: Row(
          children: <Widget>[
            DragHandle(row: widget.i),
            const VerticalDivider(width: 1),
            Expanded(
              child: ListView.separated(
                controller: _ctrl,
                itemCount: cols,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, j) => TCell(row: widget.i, col: j),
                separatorBuilder: (_, __) => const VerticalDivider(width: 1),
              ),
            ),
          ],
        ),
      ),
    );

    final draggable = drag.LongPressDraggable<Key>(
      data: key,
      axis: Axis.vertical,
      onDragStarted: () {
        DropTarget.of(context).setKey(scrollViewKey.currentContext, null);
        DropCandidateIndex.of(context).value = key.value;
      },
      onDragPositionChanged: (details) {
        DragPosition.of(context).value = details.offset;
      },
      onDragEnd: (_) {
        DragPosition.of(context).value = Offset.zero;
        DropCandidateIndex.of(context).value = null;
      },
      childWhenDragging: const SizedBox.shrink(),
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

    return VsyncProvider(
      isSingleTicker: false,
      child: drag.DragTarget<Key>(
        onWillAccept: (candidateKey) {
          final result = key != candidateKey;
          if (result) {
            DropTarget.of(context).setKey(scrollViewKey.currentContext, key);
          }
          return result;
        },
        onAccept: (row) {
          print('onAccept: $row');
        },
        builder: (BuildContext context, List<Key> candidateData, _) =>
            _dragTargetBuilder(context, candidateData, draggable, content, key),
      ),
    );
  }

  Widget _dragTargetBuilder(BuildContext context, List<Key> candidateData,
      Widget draggable, Widget content, Key contentKey) {
    const duration = Duration(milliseconds: 100);

    final targetIndex = (contentKey as ValueKey<int>).value;

    return ValueListenableBuilder(
      valueListenable: DropCandidateIndex.of(context),
      builder: (context, candidateIndex, _) {
        return ValueListenableBuilder(
          valueListenable: DragPosition.of(context),
          builder: (context, position, child) {
            final candidateIndex = DropCandidateIndex.of(context).value;

            if (candidateIndex == null ||
                (candidateIndex - targetIndex).abs() > 1) {
              return draggable;
            }

            final targetPos = DropTarget.of(context).position.dy;
            final targetHeight = DropTarget.of(context).height;

            final candidatePos = DragPosition.of(context).value.dy;
            final candidateHeight = candidateIndex != null
                ? TableSizeBloc.of(context).rowHeight(candidateIndex)
                : 0.0;

//          final combinedHeight = targetHeight + candidateHeight;
//          final h = combinedHeight / 2;
//          final isCandidateAbove = candidatePos + h < targetPos + h;

            final isCandidateAbove = candidatePos < targetPos + targetHeight;

            print('ValueListenableBuilder: $targetIndex');

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedSize(
                  duration: duration,
                  vsync: VsyncProvider.of(context),
                  child: isCandidateAbove
                      ? SizedBox(height: candidateHeight)
                      : const SizedBox.shrink(),
                ),
                child,
                AnimatedSize(
                  duration: duration,
                  vsync: VsyncProvider.of(context),
                  child: !isCandidateAbove
                      ? SizedBox(height: candidateHeight)
                      : const SizedBox.shrink(),
                ),
              ],
            );
          },
          child: candidateData.isNotEmpty || candidateIndex == targetIndex - 1
              ? content
              : draggable,
        );
      },
    );
  }
}
