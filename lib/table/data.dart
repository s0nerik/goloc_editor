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
