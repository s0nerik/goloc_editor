import 'package:flutter/material.dart';
import 'package:goloc_editor/document_bloc.dart';
import 'package:goloc_editor/table/data.dart';
import 'package:goloc_editor/table/table_row.dart';
import 'package:goloc_editor/table/table_section.dart';
import 'package:goloc_editor/table_size_bloc.dart';
import 'package:goloc_editor/util/bloc.dart';
import 'package:goloc_editor/util/widget_util.dart';
import 'package:goloc_editor/widget/async.dart';
import 'package:provider/provider.dart';

class TableEditor extends StatelessWidget {
  final String source;

  const TableEditor({
    Key key,
    @required this.source,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(builder: (_) => DocumentBloc(source)),
        ChangeNotifierProvider(builder: (_) => TableHorizontalPosition()),
        ChangeNotifierProvider(builder: (_) => DragPosition()),
        ChangeNotifierProvider(builder: (_) => DropCandidateIndex()),
        ChangeNotifierProvider(builder: (_) => DropTarget()),
      ],
      child: _EditorContent(),
    );
  }
}

class _EditorContent extends StatelessWidget {
  const _EditorContent({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleFutureBuilder<Document>(
      future: DocumentBloc.of(context).document.firstWhere((d) => d.rows > 0),
      builder: (document) => BlocProvider(
        builder: (context) => TableSizeBloc(
          data: document.data,
          cellWidth: cellWidth,
          style: inherited<DefaultTextStyle>(context, listen: false).style,
          textScaleFactor: inherited<MediaQuery>(context, listen: false)
              .data
              .textScaleFactor,
          padding: padding,
        ),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Container(
              color: Colors.black12,
              child: SafeArea(child: SizedBox.shrink()),
            ),
          ),
          body: Column(
            children: <Widget>[
              Material(
                color: Theme.of(context).appBarTheme.color,
                elevation: 4,
                child: TRow(i: 0),
              ),
              Expanded(
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      maintainState: true,
                      opaque: true,
                      builder: (context) => CustomScrollView(
                        key: scrollViewKey,
                        slivers: document.sections
                            .map((s) => TSection(section: s))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}