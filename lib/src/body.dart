import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';

extension StringToBody on String {
  /// Creates a new body from the given string.
  Body toBody() => Body.wrap(Uint8List.fromList(utf8.encode(this)));
}

extension MapToBody on Map<String, Object?> {
  /// Creates a new json body from the given map.
  Body toBody() => Body.wrap(Uint8List.fromList(utf8.encode(jsonEncode(json))));
}

extension StreamBytesToBody on Stream<Uint8List> {
  /// Creates a new body from the given stream.
  Body toBody() => Body.wrapStream(this);
}

extension StreamListIntToBody on Stream<List<int>> {
  /// Creates a new body from the given stream.
  Body toBody() => Body.wrapStream(cast());
}

extension BytesToBody on Uint8List {
  /// Creates a new body from the given byte array.
  Body toBody() => Body.wrap(this);
}

// todo move file so not dependent on io
extension FileToBody on File {
  /// Creates a new body from the given file.
  Body toBody() => Body.wrapStream(openRead().map((e) => Uint8List.fromList(e)));
}

sealed class Body {
  /// Creates a new body from the given byte array.
  /// The array should not be modified after passing it to this method.
  const factory Body.wrap(Uint8List bytes) = BytesBody._;

  /// Creates a new body from the given stream.
  /// The stream should not be modified, such as being listened on, after passing it to this method.
  /// Nor the elements of the stream should be modified.
  const factory Body.wrapStream(Stream<Uint8List> stream) = StreamingBody._;

  /// Creates an empty body.
  const factory Body.empty() = BytesBody._empty;

  /// Returns the body as a byte array if it is a byte array, otherwise `null`.
  Uint8List? asBytes();
}

final class StreamingBody implements Body {
  @internal
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
  Uint8List asBytes() => _bytes?.asUnmodifiableView() ?? Uint8List(0).asUnmodifiableView();
}
