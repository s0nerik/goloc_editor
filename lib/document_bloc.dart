import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/widgets.dart';
import 'package:goloc_editor/bloc.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class DocumentBloc implements Bloc {
  final String _source;

  final BehaviorSubject<List<List<String>>> _data = BehaviorSubject.seeded([]);
  List<List<String>> get data => _data.value;

  Stream<int> get rows => _data.map((d) => d.length).distinct();
  Stream<int> get cols => _data
      .map((d) => d.firstWhere((_) => true, orElse: () => null)?.length ?? 0)
      .distinct();

  Stream<String> getCell(int row, int col) =>
      _data.map((data) => data[row][col]).distinct();

  String getCurrentCellValue(int row, int col) => _data.value[row][col];
  List<String> getCurrentRowValue(int row) => _data.value[row];

  DocumentBloc(this._source) {
    _init();
  }

  void setCell(int row, int col, String value) {
    final list = _data.value;
    list[row][col] = value;
    _data.value = list;
  }

  Future<void> _init() async {
    final csvString = await File(_source).readAsString();
    final csvList = const CsvToListConverter().convert(csvString);
    final mappedList =
        csvList.map((row) => row.map((col) => col as String).toList()).toList();
    _data.value = mappedList;
  }

  @override
  void dispose() {
    _data?.close();
  }

  static DocumentBloc of(BuildContext context) =>
      Provider.of<DocumentBloc>(context, listen: false);
}
