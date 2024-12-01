import 'package:flutter/material.dart';

abstract class LoadingBuilder<T> extends StatelessWidget {
  final Widget? errorWidget;
  final Widget? noDataWidget;
  final Widget Function(BuildContext context, T data) builder;

  const LoadingBuilder(
      {super.key, this.errorWidget, this.noDataWidget, required this.builder});

  Widget _loadData(BuildContext context, AsyncSnapshot<T> snapshot) {
    if (snapshot.hasError) {
      return errorWidget ?? Placeholder();
    }

    if (!snapshot.hasData) {
      return noDataWidget ?? const Center(child: CircularProgressIndicator());
    }

    return builder(context, snapshot.data as T);
  }
}

class LoadingFutureBuilder<T> extends LoadingBuilder<T> {
  final Future<T> future;

  const LoadingFutureBuilder(
      {super.key,
      required this.future,
      super.errorWidget,
      super.noDataWidget,
      required super.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
        future: future,
        builder: (context, snapshot) => _loadData(context, snapshot));
  }
}

class LoadingStreamBuilder<T> extends LoadingBuilder<T> {
  final Stream<T> stream;

  const LoadingStreamBuilder(
      {super.key,
      required this.stream,
      super.errorWidget,
      super.noDataWidget,
      required super.builder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: stream,
        builder: (context, snapshot) => _loadData(context, snapshot));
  }
}
