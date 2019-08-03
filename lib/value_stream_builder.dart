import 'dart:async';

import 'package:flutter/widgets.dart';

typedef ValueStreamWidgetBuilder<T> = Widget Function(
    BuildContext context, T value);

class ValueStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final T initialValue;
  final ValueStreamWidgetBuilder<T> builder;

  const ValueStreamBuilder({
    Key key,
    @required this.stream,
    @required this.initialValue,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      initialData: initialValue,
      builder: (context, snapshot) => builder(context, snapshot.data),
    );
  }
}
