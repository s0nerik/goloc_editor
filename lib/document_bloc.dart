import 'dart:async';
import 'dart:collection';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:goloc_editor/util/bloc.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

@immutable
class Document {
  final List<List<String>> _data;
  final List<Section> _sections;
  final int _sectionNameColumnIndex;

  List<List<String>> get data => UnmodifiableListView(_data);

  int get rows => _data.length;
  int get cols {
    if (_data.length == 0) return 0;
    int cols = _data[0].length;
    if (hasSections) {
      return cols - 1; // Minus section title column
    } else {
      return cols;
    }
  }

  bool get hasSections => _sectionNameColumnIndex >= 0;
  List<Section> get sections => UnmodifiableListView(_sections);

  Document(this._data)
      : _sectionNameColumnIndex = _getSectionNameColumnIndex(_data),
        _sections = _getSections(_data);

  static int _getSectionNameColumnIndex(List<List<String>> data) {
    if (data.isEmpty) {
      return -1;
    }
    return data[0].indexWhere((e) => e.contains('comment'));
  }

  static List<Section> _getSections(List<List<String>> data) {
    if (data.isEmpty) {
      return const [];
    }

    final result = <Section>[];
    final sectionNameColumnIndex = _getSectionNameColumnIndex(data);

    int lastSectionRowOffset;
    int lastSectionLength;
    String lastSectionTitle;

    int rowOffset = 0;
    data.skip(1).forEach((row) {
      rowOffset++;
      final sectionTitle = row[sectionNameColumnIndex];
      if (sectionTitle?.isNotEmpty == true) {
        if (lastSectionTitle?.isNotEmpty == true) {
          result.add(Section(
              lastSectionRowOffset, lastSectionLength, lastSectionTitle));
        }
        lastSectionRowOffset = rowOffset;
        lastSectionTitle = sectionTitle;
        lastSectionLength = 0;
      } else {
        lastSectionLength++;
      }
    });
    if (lastSectionTitle?.isNotEmpty == true) {
      result.add(
          Section(lastSectionRowOffset, lastSectionLength, lastSectionTitle));
    }
    return result;
  }

  String getHeader(int row) => _data[row][_sectionNameColumnIndex];

  void _setHeader(int row, String value) {
    _data[row][_sectionNameColumnIndex] = value;
  }

  String getCell(int row, int col) =>
      _data[row][_getRealColumnIndex(col, _sectionNameColumnIndex)];

  void _setCell(int row, int col, String value) {
    _data[row][_getRealColumnIndex(col, _sectionNameColumnIndex)] = value;
  }

  static int _getRealColumnIndex(int col, int sectionNameColIndex) {
    if (sectionNameColIndex < 0) {
      return col;
    }
    if (col < sectionNameColIndex) {
      return col;
    } else {
      return col + 1;
    }
  }

  static final Document empty = Document(const []);
}

@immutable
class Section {
  final int row;
  final int length;
  final String title;

  const Section(this.row, this.length, this.title);
}

class DocumentBloc implements Bloc {
  final String _source;

  final BehaviorSubject<Document> _document =
      BehaviorSubject.seeded(Document([]));
  ValueObservable<Document> get document => _document;
  Stream<int> get cols => document.map((d) => d.cols);

  Stream<String> getCell(int row, int col) =>
      _document.map((d) => d.getCell(row, col)).distinct();

  String getCurrentCellValue(int row, int col) =>
      _document.value.getCell(row, col);

  String getCurrentHeaderValue(int row) => _document.value.getHeader(row);

  DocumentBloc(this._source) {
    _init();
  }

  void setHeader(int row, String value) {
    final document = _document.value;
    document._setHeader(row, value);
    _document.value = document;
  }

  void setCell(int row, int col, String value) {
    final document = _document.value;
    document._setCell(row, col, value);
    _document.value = document;
  }

  Future<void> _init() async {
    // final csvString = await File(_source).readAsString();
    final csvString = await rootBundle.loadString('assets/localizations.csv');
    final csvList = const CsvToListConverter().convert(csvString);
    final mappedList =
        csvList.map((row) => row.map((col) => col as String).toList()).toList();
    _document.value = Document(mappedList);
  }

  @override
  void dispose() {
    _document?.close();
  }

  static DocumentBloc of(BuildContext context) =>
      Provider.of<DocumentBloc>(context, listen: false);
}
