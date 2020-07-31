import 'package:flutter/widgets.dart';
import 'package:goloc_editor/table/src/data.dart';

class DragHandle extends StatelessWidget {
  const DragHandle({
    Key key,
    @required this.row,
  }) : super(key: key);

  final int row;

  @override
  Widget build(BuildContext context) {
    if (row == 0) {
      return const SizedBox(width: rowIndicatorWidth);
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: rowIndicatorWidth,
        alignment: Alignment.topCenter,
        padding: padding,
        child: Text('•', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
