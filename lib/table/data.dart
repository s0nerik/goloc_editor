import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

const double cellWidth = 128;
const double rowIndicatorWidth = 32;
const padding = EdgeInsets.all(8.0);

final scrollViewKey = GlobalKey(debugLabel: 'scrollViewKey');

class TableHorizontalPosition extends ValueNotifier<double> {
  TableHorizontalPosition() : super(0);

  static TableHorizontalPosition of(BuildContext context) =>
      Provider.of(context, listen: false);
}

class TableVerticalPosition extends ValueNotifier<double> {
  TableVerticalPosition() : super(0);

  @override
  set value(double newValue) {
    print('TableVerticalPosition: $newValue');
    super.value = newValue;
  }

  static TableVerticalPosition of(BuildContext context) =>
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
    if (_indices.isNotEmpty) {
      _indices.clear();
      notifyListeners();
    }
  }

  static DropTargets of(BuildContext context, {bool listen = true}) =>
      Provider.of(context, listen: listen);
}
