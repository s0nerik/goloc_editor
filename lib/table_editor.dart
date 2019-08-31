import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:goloc_editor/document_bloc.dart';
import 'package:goloc_editor/table_size_bloc.dart';
import 'package:goloc_editor/util/bloc.dart';
import 'package:goloc_editor/util/element_info.dart';
import 'package:goloc_editor/util/widget_util.dart';
import 'package:goloc_editor/widget/async.dart';
import 'package:goloc_editor/widget/drag_target.dart' as drag;
import 'package:provider/provider.dart';
import 'package:vsync_provider/vsync_provider.dart';

const double _cellWidth = 128;
const double _rowIndicatorWidth = 32;
const _padding = const EdgeInsets.all(8.0);

final _scrollViewKey = GlobalKey(debugLabel: '_scrollViewKey');

class _TableOffset extends ValueNotifier<double> {
  _TableOffset() : super(0);
}

class _DragPosition extends ValueNotifier<Offset> {
  _DragPosition() : super(Offset.zero);

  static _DragPosition of(BuildContext context) =>
      Provider.of(context, listen: false);
}

class _DropCandidateIndex extends ValueNotifier<int> {
  _DropCandidateIndex() : super(null);

  static _DropCandidateIndex of(BuildContext context) =>
      Provider.of(context, listen: false);
}

class _DropTarget extends ElementInfoNotifier {
  static _DropTarget of(BuildContext context) =>
      Provider.of(context, listen: false);
}

class TableEditor extends StatelessWidget {
  final String source;

  const TableEditor({
    Key key,
    @required this.source,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(builder: (_) => DocumentBloc(source)),
        ChangeNotifierProvider(builder: (_) => _TableOffset()),
        ChangeNotifierProvider(builder: (_) => _DragPosition()),
        ChangeNotifierProvider(builder: (_) => _DropCandidateIndex()),
        ChangeNotifierProvider(builder: (_) => _DropTarget()),
      ],
      child: _EditorContent(),
    );
  }
}

class _EditorContent extends StatelessWidget {
  const _EditorContent({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleFutureBuilder<Document>(
      future: DocumentBloc.of(context).document.firstWhere((d) => d.rows > 0),
      builder: (document) => BlocProvider(
        builder: (context) => TableSizeBloc(
          data: document.data,
          cellWidth: _cellWidth,
          style: inherited<DefaultTextStyle>(context, listen: false).style,
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
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      maintainState: true,
                      opaque: true,
                      builder: (context) => CustomScrollView(
                        key: _scrollViewKey,
                        slivers: document.sections
                            .map((s) => _Section(section: s))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final Section section;

  const _Section({
    Key key,
    @required this.section,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
      header: Material(
        color: Colors.blueGrey,
        elevation: 4,
        child: Row(
          children: <Widget>[
            Container(
              width: _rowIndicatorWidth,
              child: const Icon(
                Icons.drag_handle,
                size: 16,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: TextField(
                controller: TextEditingController(
                  text: DocumentBloc.of(context)
                      .getCurrentHeaderValue(section.row),
                ),
                decoration: const InputDecoration(
                  contentPadding: _padding,
                  border: InputBorder.none,
                ),
                style: DefaultTextStyle.of(context)
                    .style
                    .copyWith(color: Colors.white),
                maxLines: null,
                onChanged: (text) {
                  DocumentBloc.of(context).setHeader(section.row, text);
                },
              ),
            ),
          ],
        ),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _Row(i: section.row + i + 1),
          childCount: section.length,
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

class _RowState extends State<_Row> with TickerProviderStateMixin {
  ScrollController _ctrl;
  _TableOffset _tableOffset;

  StreamSubscription _heightSub;
  StreamSubscription _colsSub;

  @override
  void initState() {
    super.initState();
    _tableOffset = Provider.of<_TableOffset>(context, listen: false);
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

    final content = Container(
      key: key,
      color: widget.i % 2 == 1 ? Colors.transparent : Colors.black12,
      child: SizedBox(
        height: height,
        child: Row(
          children: <Widget>[
            _RowDragHandle(row: widget.i),
            const VerticalDivider(width: 1),
            Expanded(
              child: ListView.separated(
                controller: _ctrl,
                itemCount: cols,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, j) => _Cell(row: widget.i, col: j),
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
        _DropTarget.of(context).setKey(_scrollViewKey.currentContext, null);
        _DropCandidateIndex.of(context).value = key.value;
      },
      onDragPositionChanged: (details) {
        _DragPosition.of(context).value = details.offset;
      },
      onDragEnd: (_) {
        _DragPosition.of(context).value = Offset.zero;
        _DropCandidateIndex.of(context).value = null;
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
            _DropTarget.of(context).setKey(_scrollViewKey.currentContext, key);
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
      valueListenable: _DropCandidateIndex.of(context),
      builder: (context, candidateIndex, _) {
        if (candidateIndex == null) {
          return draggable;
        }

        return ValueListenableBuilder(
          valueListenable: _DragPosition.of(context),
          builder: (context, position, child) {
            final targetPos = _DropTarget.of(context).position.dy;
            final targetHeight = _DropTarget.of(context).height;

            final candidateIndex = _DropCandidateIndex.of(context).value;

            final candidatePos = _DragPosition.of(context).value.dy;
            final candidateHeight = candidateIndex != null
                ? TableSizeBloc.of(context).rowHeight(candidateIndex)
                : 0.0;

//          final combinedHeight = targetHeight + candidateHeight;
//          final h = combinedHeight / 2;
//          final isCandidateAbove = candidatePos + h < targetPos + h;

            final isCandidateAbove = candidatePos < targetPos + targetHeight;

            print('${candidatePos.toInt()}');
//          print(
//              '${candidatePos.toInt()} + ${h.toInt()} < ${targetPos.toInt()} + ${h.toInt()} = $isCandidateAbove');

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
        decoration: const InputDecoration(
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

class _RowDragHandle extends StatelessWidget {
  final int row;

  const _RowDragHandle({
    Key key,
    @required this.row,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (row == 0) {
      return const SizedBox(width: _rowIndicatorWidth);
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: _rowIndicatorWidth,
        alignment: Alignment.topCenter,
        padding: _padding,
        child: Text('•', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
