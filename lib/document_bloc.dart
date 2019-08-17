import 'dart:async';

import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:goloc_editor/util/bloc.dart';
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

@immutable
class Section {
  final String title;
  final List<List<String>> data;

  const Section(this.title, this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Section &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          const DeepCollectionEquality().equals(data, other.data);

  @override
  int get hashCode => title.hashCode ^ data.hashCode;

  static const Section empty = Section('', []);
}

class DocumentBloc implements Bloc {
  final String _source;

  final BehaviorSubject<List<List<String>>> _data = BehaviorSubject.seeded([]);
  List<List<String>> get data => _data.value;

  Stream<List<int>> get sectionIndices => _data.map(_sectionIndices);
  Stream<List<Section>> get sections => _data.map(_sections);

  Stream<DocumentSize> get size => _data.map(_size).distinct();
  Stream<int> get rows => size.map((s) => s.rows).distinct();
  Stream<int> get cols => size.map((s) => s.cols).distinct();

  Stream<String> getCell(int row, int col) =>
      _data.map((data) => _cell(data, row, col)).distinct();

  String getCurrentCellValue(int row, int col) => _cell(data, row, col);

  DocumentBloc(this._source) {
    _init();
    sections.listen((sections) {
      print('sections: ${sections.length}');
    });
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

DocumentSize _size(List<List<String>> data) {
  if (data.isNotEmpty) {
    int rowLength = data[0].length;
    if (_sectionNameColumnIndex(data) >= 0) {
      rowLength -= 1;
    }
    return DocumentSize(data.length, rowLength);
  } else {
    return DocumentSize.empty;
  }
}

String _cell(List<List<String>> data, int row, int col) {
  final excludedIndex = _sectionNameColumnIndex(data);
  if (excludedIndex < 0) {
    return data[row][col];
  }
  if (col < excludedIndex) {
    return data[row][col];
  } else {
    return data[row][col + 1];
  }
}

List<Section> _sections(List<List<String>> data) {
  if (data.isEmpty) {
    return const [Section.empty];
  }

  final result = <Section>[];
  final sectionTitleColIndex = _sectionNameColumnIndexByRow(data[0]);

  String lastSectionTitle = '';
  List<List<String>> lastSectionData = [];
  data.skip(1).forEach((row) {
    final sectionTitle = row[sectionTitleColIndex];
    if (sectionTitle?.isNotEmpty == true) {
      if (lastSectionTitle?.isNotEmpty == true) {
        result.add(Section(lastSectionTitle, lastSectionData));
      }
      lastSectionTitle = sectionTitle;
      lastSectionData = [];
    }
    lastSectionData.add(row);
  });
  result.add(Section(lastSectionTitle, lastSectionData));
  return result;
}

int _sectionCount(List<List<String>> data) =>
    data.where((row) => _sectionNameColumnIndexByRow(row) >= 0).length;

List<int> _sectionIndices(List<List<String>> data) {
  final result = <int>[];
  for (int i = 0; i < data.length; i++) {
    if (_sectionNameColumnIndexByRow(data[i]) >= 0) {
      result.add(i);
    }
  }
  return result;
}

int _sectionNameColumnIndex(List<List<String>> data) {
  final firstRow = data?.firstWhere((_) => true, orElse: () => null);
  if (firstRow == null) {
    return -1;
  }
//  return -1; // TODO: section handling
  return _sectionNameColumnIndexByRow(firstRow);
}

int _sectionNameColumnIndexByRow(List<String> row) =>
    row.indexWhere((e) => e.contains('comment'));
