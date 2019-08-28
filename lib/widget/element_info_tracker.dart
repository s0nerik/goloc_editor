import 'package:flutter/widgets.dart';
import 'package:goloc_editor/util/element_info.dart';

typedef ElementInfoBuilder = Widget Function(
    BuildContext context, ElementInfo selfInfo, ElementInfo otherInfo);

class ElementInfoTracker extends StatefulWidget {
  final GlobalKey parentKey;
  final Key selfKey;
  final Key otherKey;
  final ElementInfoBuilder builder;

  const ElementInfoTracker({
    Key key,
    @required this.parentKey,
    @required this.selfKey,
    @required this.otherKey,
    @required this.builder,
  }) : super(key: key);

  @override
  _ElementInfoTrackerState createState() => _ElementInfoTrackerState();
}

class _ElementInfoTrackerState extends State<ElementInfoTracker> {
  ElementInfo _selfInfo = ElementInfo.empty;
  ElementInfo _otherInfo = ElementInfo.empty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_selfCallback);
    WidgetsBinding.instance.addPostFrameCallback(_otherCallback);
  }

  @override
  void didUpdateWidget(ElementInfoTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selfKey != widget.selfKey) {
      _selfInfo = ElementInfo.empty;
    }
    if (oldWidget.otherKey != widget.otherKey) {
      _otherInfo = ElementInfo.empty;
    }
  }

  void _selfCallback(_) {
    if (mounted) {
      final info =
          ElementInfo.find(widget.parentKey.currentContext, widget.selfKey);
      print('self position: ${info.position}');
      if (_selfInfo != info) {
        setState(() {
          _selfInfo = info;
        });
      }
//      final ctx = widget.selfKey?.currentContext;
//      if (ctx != null) {
//        final info = ElementInfo.context(widget.selfKey.currentContext);
//        if (_selfInfo != info) {
//          setState(() {
//            _selfInfo = info;
//          });
//        }
//      }
      WidgetsBinding.instance.addPostFrameCallback(_selfCallback);
    }
  }

  void _otherCallback(_) {
    if (mounted) {
      final info =
          ElementInfo.find(widget.parentKey.currentContext, widget.selfKey);
      print('other position: ${info.position}');
      if (_otherInfo != info) {
        setState(() {
          _otherInfo = info;
        });
      }
//      final ctx = widget.otherKey?.currentContext;
//      if (ctx != null) {
//        final info = ElementInfo.context(ctx);
//        if (_otherInfo != info) {
//          setState(() {
//            _otherInfo = info;
//          });
//        }
//      }
      WidgetsBinding.instance.addPostFrameCallback(_otherCallback);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _selfInfo, _otherInfo);
  }
}
