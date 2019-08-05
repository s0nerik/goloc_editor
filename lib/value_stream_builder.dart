import 'dart:async';

import 'package:flutter/widgets.dart';

typedef ValueStreamWidgetBuilder<T> = Widget Function(
    BuildContext context, T value);

class ValueStreamBuilder<T> extends StatefulWidget {
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
  _ValueStreamBuilderState<T> createState() => _ValueStreamBuilderState<T>();
}

class _ValueStreamBuilderState<T> extends State<ValueStreamBuilder<T>> {
  T _value;
  StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _sub = widget.stream.listen((value) {
      setState(() {
        _value = value;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _value);
  }
}
