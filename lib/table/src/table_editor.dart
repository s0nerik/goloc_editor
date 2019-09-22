import 'package:flutter/material.dart';
import 'package:goloc_editor/document_bloc.dart';
import 'package:goloc_editor/table/src/data.dart';
import 'package:goloc_editor/table/src/table_bloc.dart';
import 'package:goloc_editor/table/src/table_row.dart';
import 'package:goloc_editor/table/src/table_section.dart';
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
      ],
      child: Consumer<DocumentBloc>(
        builder: (context, bloc, _) => SimpleFutureBuilder<Document>(
          future: bloc.document.firstWhere((d) => d.rows > 0),
          builder: (document) => BlocProvider(
            builder: (context) => TableBloc(
              data: document.data,
              cellWidth: cellWidth,
              style: inherited<DefaultTextStyle>(context, listen: false).style,
              textScaleFactor: inherited<MediaQuery>(context, listen: false)
                  .data
                  .textScaleFactor,
              padding: padding,
            ),
            child: _EditorContent(document: document),
          ),
        ),
      ),
    );
  }
}

class _EditorContent extends StatefulWidget {
  final Document document;

  const _EditorContent({
    Key key,
    @required this.document,
  }) : super(key: key);

  @override
  _EditorContentState createState() => _EditorContentState();
}

class _EditorContentState extends State<_EditorContent> {
  final _ctrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_updatePosition);
  }

  void _updatePosition() {
    TableBloc.of(context).verticalOffset.value = _ctrl.position.pixels;
  }

  @override
  void dispose() {
    _ctrl.removeListener(_updatePosition);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    controller: _ctrl,
                    slivers: widget.document.sections
                        .map((s) => TSection(section: s))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
