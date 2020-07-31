import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

typedef ContentBuilder<T> = Widget Function(T data);
typedef ValueStreamWidgetBuilder<T> = Widget Function(
    BuildContext context, T data);

/// A [FutureBuilder] that displays a [progressIndicator] until [future] is fetched.
/// In case of error - shows a [errorIndicator].
class SimpleFutureBuilder<T> extends StatelessWidget {
  const SimpleFutureBuilder({
    Key key,
    @required this.future,
    @required this.builder,
    this.progressIndicator = const Center(child: CircularProgressIndicator()),
    this.errorIndicator = const Center(child: Icon(Icons.error)),
  }) : super(key: key);

  final Future<T> future;
  final Widget progressIndicator;
  final Widget errorIndicator;
  final ContentBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return progressIndicator;
          case ConnectionState.done:
            if (snapshot.hasError) {
              return errorIndicator;
            }
            return builder(snapshot.data);
          default:
            throw UnsupportedError(
                'Connection state ${snapshot.connectionState} is not supported');
        }
      },
    );
  }
}

/// A wrapper over [StreamBuilder] that invokes [builder] with stream data assuming that the stream will never produce an error.
class ValueStreamBuilder<T> extends StatelessWidget {
  const ValueStreamBuilder({
    Key key,
    @required this.stream,
    @required this.initialValue,
    @required this.builder,
  }) : super(key: key);

  final Stream<T> stream;
  final T initialValue;
  final ValueStreamWidgetBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          throw ArgumentError(
              'Stream should not produce any errors to be used with ValueStreamBuilder. Error: ${snapshot.error}');
        }
        return builder(context, snapshot.requireData);
      },
    );
  }
}

/// A wrapper over [ValueStreamBuilder] that automatically provides initial value to the builder.
class ValueObservableBuilder<T> extends StatelessWidget {
  const ValueObservableBuilder({
    Key key,
    @required this.stream,
    @required this.builder,
  }) : super(key: key);

  final ValueStream<T> stream;
  final ValueStreamWidgetBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return ValueStreamBuilder<T>(
      stream: stream,
      initialValue: stream.value,
      builder: builder,
    );
  }
}

typedef MultiValueStreamWidgetBuilder = Widget Function(
    BuildContext context, List<Object> values);

/// A wrapper over [ValueStreamBuilder] that automatically provides [builder] with latest values from each stream.
class MultiValueObservableBuilder extends StatelessWidget {
  const MultiValueObservableBuilder({
    Key key,
    @required this.streams,
    @required this.builder,
  }) : super(key: key);

  final List<ValueStream> streams;
  final MultiValueStreamWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ValueStreamBuilder<List<Object>>(
      stream: Rx.combineLatestList<Object>(streams),
      initialValue: streams.map<Object>((s) => s.value).toList(growable: false),
      builder: builder,
    );
  }
}

typedef ValueStreamWidgetBuilder2<T1, T2> = Widget Function(
    BuildContext context, T1 value1, T2 value2);

/// A wrapper over [ValueObservableBuilder] that automatically provides [builder] with latest values from each stream.
class ValueObservableBuilder2<T1, T2> extends StatelessWidget {
  const ValueObservableBuilder2({
    Key key,
    @required this.stream1,
    @required this.stream2,
    @required this.builder,
  }) : super(key: key);

  final ValueStream<T1> stream1;
  final ValueStream<T2> stream2;
  final ValueStreamWidgetBuilder2<T1, T2> builder;

  @override
  Widget build(BuildContext context) {
    return MultiValueObservableBuilder(
      streams: [stream1, stream2],
      builder: (context, values) =>
          builder(context, values[0] as T1, values[1] as T2),
    );
  }
}

typedef ValueStreamWidgetBuilder3<T1, T2, T3> = Widget Function(
    BuildContext context, T1 value1, T2 value2, T3 value3);

/// A wrapper over [ValueObservableBuilder] that automatically provides [builder] with latest values from each stream.
class ValueObservableBuilder3<T1, T2, T3> extends StatelessWidget {
  const ValueObservableBuilder3({
    Key key,
    @required this.stream1,
    @required this.stream2,
    @required this.stream3,
    @required this.builder,
  }) : super(key: key);

  final ValueStream<T1> stream1;
  final ValueStream<T2> stream2;
  final ValueStream<T3> stream3;
  final ValueStreamWidgetBuilder3<T1, T2, T3> builder;

  @override
  Widget build(BuildContext context) {
    return MultiValueObservableBuilder(
      streams: [stream1, stream2, stream3],
      builder: (context, values) =>
          builder(context, values[0] as T1, values[1] as T2, values[2] as T3),
    );
  }
}
