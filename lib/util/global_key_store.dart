import 'package:flutter/widgets.dart';

class GlobalKeyStore<T> {
  final _keys = <T, GlobalKey>{};

  GlobalKey operator [](T key) {
    GlobalKey result = _keys[key];
    if (result == null) {
      result = GlobalKey();
      _keys[key] = result;
    }
    return result;
  }
}
