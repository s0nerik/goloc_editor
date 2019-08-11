import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';

abstract class Bloc {
  void dispose();
}

class BlocProvider<T extends Bloc> extends Provider<T> {
  BlocProvider({
    Key key,
    @required ValueBuilder<T> builder,
    Widget child,
  }) : super(
          key: key,
          builder: builder,
          dispose: (_, bloc) => bloc.dispose(),
          child: child,
        );
}
