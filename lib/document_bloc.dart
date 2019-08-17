import 'dart:async';
import 'dart:math';

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
  final int sections;

  const DocumentSize(this.rows, this.cols, this.sections);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentSize &&
          runtimeType == other.runtimeType &&
          rows == other.rows &&
          cols == other.cols &&
          sections == other.sections;

  @override
  int get hashCode => rows.hashCode ^ cols.hashCode ^ sections.hashCode;

  static const empty = DocumentSize(0, 0, 0);
}

@immutable
class Section {
  final int rowOffset;
  final String title;
  final List<List<String>> data;

  const Section(this.rowOffset, this.title, this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Section &&
          rowOffset == other.rowOffset &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => rowOffset.hashCode ^ title.hashCode ^ data.hashCode;

  static const Section empty = Section(0, '', []);
}

class DocumentBloc implements Bloc {
  final String _source;

  final BehaviorSubject<List<List<String>>> _data = BehaviorSubject.seeded([]);
  List<List<String>> get data => _data.value;
  Stream<List<Section>> get sections => _data.map(_sections);

  Stream<DocumentSize> get size =>
      Observable.zip2(_data, sections, _size).distinct();
  Stream<int> get sectionsAmount => size.map((s) => s.sections).distinct();
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

DocumentSize _size(List<List<String>> data, List<Section> sections) {
  if (data.isEmpty) {
    return DocumentSize.empty;
  }

  if (sections.isEmpty) {
    return DocumentSize.empty;
  }

  final rows = data.length;
  int cols = 0;
  for (final row in data) {
    cols = max(cols, row.length);
  }

  if (sections.length > 1 || sections[0].title.isNotEmpty) {
    cols -= 1;
  }

  return DocumentSize(rows, cols, sections.length);
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
  int lastRowOffset = 1;
  int rowOffset = 0;
  data.skip(1).forEach((row) {
    rowOffset++;
    final sectionTitle = row[sectionTitleColIndex];
    if (sectionTitle?.isNotEmpty == true) {
      if (lastSectionTitle?.isNotEmpty == true) {
        result.add(Section(lastRowOffset, lastSectionTitle, lastSectionData));
      }
      lastRowOffset = rowOffset;
      lastSectionTitle = sectionTitle;
      lastSectionData = [];
    }
    lastSectionData.add(row);
  });
  result.add(Section(lastRowOffset, lastSectionTitle, lastSectionData));
  return result;
}

int _sectionNameColumnIndex(List<List<String>> data) {
  if (data.isEmpty) {
    return -1;
  }
//  return -1; // TODO: section handling
  return _sectionNameColumnIndexByRow(data[0]);
}

int _sectionNameColumnIndexByRow(List<String> row) =>
    row.indexWhere((e) => e.contains('comment'));
