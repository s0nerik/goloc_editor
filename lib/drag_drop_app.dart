import 'package:flutter/material.dart';
import 'package:goloc_editor/table/src/util.dart';
import 'package:goloc_editor/widget/drag_drop.dart';
import 'package:provider/provider.dart';

void run() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: SafeArea(
          child: ChangeNotifierProvider(
            create: (_) => _Overlaps(),
            child: const DragSurface(
              child: _Content(),
            ),
          ),
        ),
      ),
    );
  }
}

class _Overlaps extends ValueNotifier<List<Overlap>> {
  _Overlaps() : super(const []);

  static _Overlaps of(BuildContext context, {bool listen = true}) =>
      Provider.of(context, listen: listen);
}

class _Content extends StatefulWidget {
  const _Content({
    Key key,
  }) : super(key: key);

  @override
  __ContentState createState() => __ContentState();
}

class __ContentState extends State<_Content> {
  DragDetails _dragDetails;
  ScrollController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ScrollController();
    _dragDetails = DragDetails.of(context);
    _dragDetails.addListener(_onDragChanged);
  }

  @override
  void dispose() {
    _dragDetails.removeListener(_onDragChanged);
    super.dispose();
  }

  void _onDragChanged() {
    debugPrint('TOP: ${_dragDetails.topOffset}');
    _Overlaps.of(context, listen: false).value = overlap(
      draggableY: _dragDetails.topOffset,
      draggableHeight: _dragDetails.draggableHeight,
      tableScrollAmount: _ctrl.offset,
      rowHeights: _allHeights(20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _ctrl,
      itemCount: 20,
      itemBuilder: (_, i) => _Item(i: i),
      separatorBuilder: (_, __) => const Divider(height: 0),
    );
  }
}

List<double> _allHeights(int count) {
  return List.generate(count, (i) => _heights[i % _heights.length]);
}

const _heights = <double>[
  120,
  56,
  36,
  36,
  36,
];

class _Item extends StatelessWidget {
  const _Item({
    Key key,
    @required this.i,
    this.isDragged = false,
  }) : super(key: key);

  final int i;
  final bool isDragged;

  @override
  Widget build(BuildContext context) {
    final overlaps = _Overlaps.of(context).value;
    final overlapIndex = overlaps.indexWhere((o) => o.index == i);
    final isOverlapped = overlapIndex >= 0;

    Color color;
    if (isDragged) {
      color = Colors.blue.withAlpha(122);
    } else if (isOverlapped) {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    final height = _heights[i % _heights.length];
// TODO: do something about it
//    if (isOverlapped && !isDragged) {
//      final overlapInfo = overlaps[overlapIndex];
//      if (0.5 < overlapInfo.amount && overlapInfo.amount < 1) {
//        height += DragDetails.of(context).draggableHeight;
//      }
//    }

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Container(
        color: color,
        child: Row(
          children: <Widget>[
            DragHandle(
              dragAvatarBuilder: (_) => _Item(i: i, isDragged: true),
              child: Container(
                width: 120,
                alignment: Alignment.center,
                child: const Text('X'),
              ),
            ),
            Expanded(child: Text('$i')),
          ],
        ),
      ),
    );
  }
}
