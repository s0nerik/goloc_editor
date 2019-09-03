import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

const double cellWidth = 128;
const double rowIndicatorWidth = 32;
const padding = const EdgeInsets.all(8.0);

final scrollViewKey = GlobalKey(debugLabel: 'scrollViewKey');

class TableHorizontalPosition extends ValueNotifier<double> {
  TableHorizontalPosition() : super(0);

  static TableHorizontalPosition of(BuildContext context) =>
      Provider.of(context, listen: false);
}

class DragPosition extends ValueNotifier<Offset> {
  DragPosition() : super(Offset.zero);

  static DragPosition of(BuildContext context) =>
      Provider.of(context, listen: false);
}

class DropTargets extends ChangeNotifier {
  final Set<int> _indices = Set();

  bool contains(int index) => _indices.contains(index);
  bool isLast(int index) =>
      _indices.lastWhere((_) => true, orElse: () => null) == index;

  void add(int index) {
    if (_indices.add(index)) {
      notifyListeners();
    }
  }

  void remove(int index) {
    if (_indices.remove(index)) {
      notifyListeners();
    }
  }

  void clear() {
    if (_indices.length > 0) {
      _indices.clear();
      notifyListeners();
    }
  }

  static DropTargets of(BuildContext context, {bool listen = true}) =>
      Provider.of(context, listen: listen);
}
