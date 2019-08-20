import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:goloc_editor/util/value.dart';
import 'package:meta/meta.dart';

@immutable
class ElementInfo {
  final Size size;
  final Offset position;
  final Widget widget;

  ElementInfo(Element element)
      : size = element?.size ?? Size.zero,
        position = _getPosition(element),
        widget = element?.widget;

  static Offset _getPosition(Element element) {
    final renderBox = element?.renderObject as RenderBox;
    if (renderBox?.attached == true) {
      return renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    } else {
      return Offset.zero;
    }
  }

  static ElementInfo find(BuildContext context, Key key) {
    final found = Value<Element>(null);
    context.visitChildElements((e) {
      if (found.value != null) return;
      _find(e, key, found);
    });
    return ElementInfo(found.value);
  }

  static void _find(Element e, Key key, Value<Element> found) {
    if (found.value != null) return;

    if (e.widget.key == key) {
      found.value = e;
    } else {
      e.visitChildren((e) => _find(e, key, found));
    }
  }

  static final empty = ElementInfo(null);
}

class ElementInfoNotifier extends ValueNotifier<ElementInfo> {
  double get height => value.size.height;
  Offset get position => value.position;
  Widget get widget => value.widget;

  ElementInfoNotifier() : super(ElementInfo.empty);

  @protected
  @override
  set value(ElementInfo newValue) {
    super.value = newValue;
  }

  void reset() {
    value = ElementInfo.empty;
  }

  void setKey(BuildContext context, Key key) {
    if (key == null) {
      value = ElementInfo.empty;
    }
    scheduleMicrotask(() {
      value = ElementInfo.find(context, key);
    });
  }
}
