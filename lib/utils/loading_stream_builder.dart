import 'package:flutter/material.dart';

class LoadingStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final Widget Function(BuildContext context, T data) builder;
  final Widget noDataWidget;

  const LoadingStreamBuilder(
      {super.key,
      required this.stream,
      required this.builder,
      required this.noDataWidget});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error!}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return builder(context, snapshot.data as T);
      },
    );
  }
}
