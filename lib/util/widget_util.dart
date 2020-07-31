import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

T inherited<T extends InheritedWidget>(BuildContext context,
    {bool listen = true}) {
  final widget = listen
      ? context.dependOnInheritedWidgetOfExactType<T>()
      : context.getElementForInheritedWidgetOfExactType<T>()?.widget;

  assert(widget != null);

  return widget;
}

T provided<T>(BuildContext context, {bool listen = true}) =>
    Provider.of<T>(context, listen: listen);
