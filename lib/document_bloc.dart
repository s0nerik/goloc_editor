import 'dart:async';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:goloc_editor/model/document.dart';
import 'package:goloc_editor/util/bloc.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class DocumentBloc implements Bloc {
  DocumentBloc(this._source) {
    _init();
  }

  final String _source;

  final BehaviorSubject<Document> _document =
      BehaviorSubject.seeded(Document(const []));
  ValueStream<Document> get document => _document;

  int get cols => document.value.cols;
  Stream<int> get colsStream => document.map((d) => d.cols).distinct();

  Stream<String> getCell(int row, int col) =>
      _document.map((d) => d.getCell(row, col)).distinct();

  String getCurrentCellValue(int row, int col) =>
      _document.value.getCell(row, col);

  String getCurrentHeaderValue(int row) => _document.value.getHeader(row);

  void setHeader(int row, String value) {
    final document = _document.value;
//    document._setHeader(row, value);
    _document.value = document;
  }

  void setCell(int row, int col, String value) {
    final document = _document.value;
//    document._setCell(row, col, value);
    _document.value = document;
  }

  Future<void> _init() async {
    // final csvString = await File(_source).readAsString();
    final csvString = await rootBundle.loadString('assets/localizations.csv');
//    final csvString = await rootBundle.loadString('assets/_localizations.csv');
    final csvList = const CsvToListConverter().convert(csvString);
    final mappedList = csvList.map((row) => row.cast<String>()).toList();
    _document.value = Document(mappedList);
  }

  @override
  void dispose() {
    _document?.close();
  }

  static DocumentBloc of(BuildContext context) =>
      Provider.of<DocumentBloc>(context, listen: false);
}
