import 'dart:typed_data';

sealed class Body {
  const factory Body.wrap(Uint8List bytes) = BytesBody._;
  const factory Body.wrapStream(Stream<Uint8List> stream) = StreamingBody._;

  const factory Body.empty() = BytesBody._empty;

  /// Returns the body as a byte array if it is a byte array, otherwise `null`.
  Uint8List? asBytes();
}

final class StreamingBody implements Body {
  final Stream<Uint8List> stream;

  const StreamingBody._(this.stream);

  @override
  Null asBytes() => null;
}

final class BytesBody implements Body {
  final Uint8List? _bytes;

  const BytesBody._(Uint8List bytes) : _bytes = bytes;

  const BytesBody._empty() : _bytes = null;

  @override
  Uint8List? asBytes() => _bytes?.asUnmodifiableView();
  // Uint8List asBytes() => _bytes?.asUnmodifiableView() ?? Uint8List(0).asUnmodifiableView(); // todo would this be better?
}
