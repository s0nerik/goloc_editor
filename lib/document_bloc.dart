import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class DocumentBloc {
  final String _source;

  final BehaviorSubject<List<List<String>>> _data = BehaviorSubject.seeded([]);
  Stream<int> get rows => _data.map((d) => d.length);
  Stream<int> get cols => _data
      .map((d) => d.firstWhere((_) => true, orElse: () => null)?.length ?? 0);

  Stream<String> getCell(int row, col) => _data.map((data) => data[row][col]);

  DocumentBloc(this._source) {
    _init();
  }

  Future<void> _init() async {
    final csvString = await File(_source).readAsString();
    final csvList = const CsvToListConverter().convert(csvString);
    final mappedList =
        csvList.map((row) => row.map((col) => col as String).toList()).toList();
    _data.value = mappedList;
  }

  static DocumentBloc of(BuildContext context) =>
      Provider.of<DocumentBloc>(context);
}
