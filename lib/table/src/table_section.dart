import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:goloc_editor/document_bloc.dart';
import 'package:goloc_editor/model/section.dart';
import 'package:goloc_editor/table/src/data.dart';
import 'package:goloc_editor/table/src/table_row.dart';

class TSection extends StatelessWidget {
  const TSection({
    Key key,
    @required this.section,
  }) : super(key: key);

  final Section section;

  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
      header: Material(
        color: Colors.blueGrey,
        elevation: 4,
        child: Row(
          children: <Widget>[
            Container(
              width: rowIndicatorWidth,
              child: const Icon(
                Icons.drag_handle,
                size: 16,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: TextField(
                controller: TextEditingController(
                  text: DocumentBloc.of(context)
                      .getCurrentHeaderValue(section.row),
                ),
                decoration: const InputDecoration(
                  contentPadding: padding,
                  border: InputBorder.none,
                ),
                style: DefaultTextStyle.of(context)
                    .style
                    .copyWith(color: Colors.white),
                maxLines: null,
                onChanged: (text) {
                  DocumentBloc.of(context).setHeader(section.row, text);
                },
              ),
            ),
          ],
        ),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => TRow(i: section.row + i + 1),
          childCount: section.length,
        ),
      ),
    );
  }
}
