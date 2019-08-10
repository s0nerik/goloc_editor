import 'dart:async';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:goloc_editor/bloc.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

@immutable
class DocumentSize {
  final int rows;
  final int cols;

  const DocumentSize(this.rows, this.cols);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentSize &&
          runtimeType == other.runtimeType &&
          rows == other.rows &&
          cols == other.cols;

  @override
  int get hashCode => rows.hashCode ^ cols.hashCode;

  static const empty = DocumentSize(0, 0);
}

class DocumentBloc implements Bloc {
  final String _source;

  final BehaviorSubject<List<List<String>>> _data = BehaviorSubject.seeded([]);
  List<List<String>> get data => _data.value;

  Stream<int> get rows => _data.map((d) => d.length).distinct();
  Stream<int> get cols => _data
      .map((d) => d.firstWhere((_) => true, orElse: () => null)?.length ?? 0)
      .distinct();

  Stream<DocumentSize> get size => _data.map((data) {
        if (data.isNotEmpty) {
          return DocumentSize(data.length, data[0].length);
        } else {
          return DocumentSize.empty;
        }
      }).distinct();

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
    // final csvString = await File(_source).readAsString();
    final csvString = await rootBundle.loadString('assets/localizations.csv');
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
