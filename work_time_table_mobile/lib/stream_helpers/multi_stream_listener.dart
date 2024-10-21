void listenForStreams(List<Stream> streams, void Function() action) {
  for (var s in streams) {
    s.listen((event) => action());
  }
}
