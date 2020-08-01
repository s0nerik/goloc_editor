// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TableState on _TableStateStore, Store {
  final _$xAtom = Atom(name: '_TableStateStore.x');

  @override
  bool get x {
    _$xAtom.reportRead();
    return super.x;
  }

  @override
  set x(bool value) {
    _$xAtom.reportWrite(value, super.x, () {
      super.x = value;
    });
  }

  @override
  String toString() {
    return '''
x: ${x}
    ''';
  }
}
