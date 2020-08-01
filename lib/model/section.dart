import 'package:meta/meta.dart';

@immutable
class Section {
  const Section(this.row, this.length, this.title);

  final int row;
  final int length;
  final String title;
}
