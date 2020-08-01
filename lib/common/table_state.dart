import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

part 'table_state.g.dart';

class TableState extends _TableStateStore with _$TableState {
  static TableState of(BuildContext context) =>
      Provider.of(context, listen: false);
}

abstract class _TableStateStore with Store {
  @observable
  bool x = false;
}
