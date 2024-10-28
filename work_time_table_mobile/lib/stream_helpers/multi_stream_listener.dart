import 'dart:async';

List<StreamSubscription> listenForStreams(
  List<Stream> streams,
  void Function() action,
) =>
    streams.map((s) => s.listen((event) => action())).toList();
