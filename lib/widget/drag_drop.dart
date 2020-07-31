import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class DragDetails with ChangeNotifier {
  double _topOffset = -1;
  double get topOffset => _topOffset;

  double _draggableHeight = -1;
  double get draggableHeight => _draggableHeight;

  void _update(double topOffset, double draggableHeight) {
    _topOffset = topOffset;
    _draggableHeight = draggableHeight;
    notifyListeners();
  }

  void _addTopOffset(double delta) {
    _topOffset += delta;
    notifyListeners();
  }

  static DragDetails of(BuildContext context, {bool listen = false}) =>
      Provider.of(context, listen: listen);
}

class _DragAvatarBuilder extends ValueNotifier<WidgetBuilder> {
  _DragAvatarBuilder() : super(null);

  static _DragAvatarBuilder of(BuildContext context, {bool listen = false}) =>
      Provider.of(context, listen: listen);
}

class DragSurface extends StatelessWidget {
  const DragSurface({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DragDetails()),
        ChangeNotifierProvider(create: (_) => _DragAvatarBuilder()),
      ],
      child: Overlay(
        initialEntries: [
          OverlayEntry(builder: (_) => child),
          OverlayEntry(builder: (_) => _DragSurfaceOverlay()),
        ],
      ),
    );
  }
}

class _DragSurfaceOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dragDetails = DragDetails.of(context, listen: true);
    final avatarBuilder = _DragAvatarBuilder.of(context, listen: true);
    final builder = avatarBuilder.value ?? (_) => const SizedBox.shrink();
    return Positioned.fill(
      top: dragDetails.topOffset,
      bottom: null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 3000),
        opacity: avatarBuilder != null ? 1 : 0,
        child: Builder(
          builder: builder,
        ),
      ),
    );
  }
}

class DragHandle extends StatelessWidget {
  const DragHandle({
    Key key,
    @required this.dragAvatarBuilder,
    @required this.child,
  }) : super(key: key);

  final Widget child;
  final WidgetBuilder dragAvatarBuilder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragDown: (details) {
        final RenderBox box = context.findRenderObject();
        final RenderBox overlayBox =
            Overlay.of(context).context.findRenderObject();
        final globalOffset = box.localToGlobal(Offset.zero);
        final overlayOffset = overlayBox.globalToLocal(globalOffset);
        DragDetails.of(context)._update(overlayOffset.dy, box.size.height);
        _DragAvatarBuilder.of(context).value = dragAvatarBuilder;
      },
      onVerticalDragUpdate: (details) {
        DragDetails.of(context)._addTopOffset(details.primaryDelta);
      },
      onVerticalDragEnd: (_) {
        _resetDrag(context);
      },
      onVerticalDragCancel: () => _resetDrag(context),
      child: child,
    );
  }

  void _resetDrag(BuildContext context) {
    DragDetails.of(context)._update(-1, -1);
    _DragAvatarBuilder.of(context).value = null;
  }
}
