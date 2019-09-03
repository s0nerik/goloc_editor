import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:goloc_editor/util/element_info.dart';
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

class DropCandidateIndex extends ValueNotifier<int> {
  DropCandidateIndex() : super(null);

  static DropCandidateIndex of(BuildContext context) =>
      Provider.of(context, listen: false);
}

class DropTarget extends ElementInfoNotifier {
  static DropTarget of(BuildContext context) =>
      Provider.of(context, listen: false);
}

class DraggedRows extends ChangeNotifier implements ValueListenable<Set<int>> {
  final Set<int> _indices = Set();

  @override
  Set<int> get value => _indices;

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
}
