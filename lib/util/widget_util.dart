import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

T inherited<T extends InheritedWidget>(BuildContext context,
    {bool listen = true}) {
  // this is required to get generic Type
  final type = _typeOf<T>();
  final widget = listen
      ? context.inheritFromWidgetOfExactType(type) as T
      : context.ancestorInheritedElementForWidgetOfExactType(type)?.widget as T;

  assert(widget != null);

  return widget;
}

T provided<T>(BuildContext context, {bool listen = true}) =>
    Provider.of<T>(context, listen: listen);

Type _typeOf<T>() => T;
