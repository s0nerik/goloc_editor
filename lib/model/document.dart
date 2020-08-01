import 'dart:collection';

import 'package:goloc_editor/model/section.dart';
import 'package:meta/meta.dart';

@immutable
class Document {
  Document(this._data)
      : _sectionNameColumnIndex = _getSectionNameColumnIndex(_data),
        _sections = _getSections(_data);

  final List<List<String>> _data;
  final List<Section> _sections;
  final int _sectionNameColumnIndex;

  List<List<String>> get data => UnmodifiableListView(_data);

  int get rows => _data.length;
  int get cols {
    if (_data.isEmpty) return 0;
    final cols = _data[0].length;
    if (hasSections) {
      return cols - 1; // Minus section title column
    } else {
      return cols;
    }
  }

  bool get hasSections => _sectionNameColumnIndex >= 0;
  List<Section> get sections => UnmodifiableListView(_sections);

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

    var rowOffset = 0;
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
