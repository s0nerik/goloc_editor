import 'package:meta/meta.dart';

@immutable
class Document {
  final List<List<String>> _data;
  final List<Section> _sections;
  final int _sectionNameColumnIndex;

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
  List<Section> get sections => _sections;

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
      }
      lastSectionLength++;
    });
    if (lastSectionTitle?.isNotEmpty == true) {
      result.add(
          Section(lastSectionRowOffset, lastSectionLength, lastSectionTitle));
    }
    return result;
  }

  String getCell(int row, int col) =>
      _data[row][_getRealColumnIndex(col, _sectionNameColumnIndex)];

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
}

@immutable
class Section {
  final int row;
  final int length;
  final String title;

  const Section(this.row, this.length, this.title);
}
