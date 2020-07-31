import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';

// ignore: one_member_abstracts
abstract class Bloc {
  void dispose();
}

class BlocProvider<T extends Bloc> extends Provider<T> {
  BlocProvider({
    Key key,
    @required Create<T> create,
    Widget child,
  }) : super(
          key: key,
          create: create,
          dispose: (_, bloc) => bloc.dispose(),
          child: child,
        );
}
