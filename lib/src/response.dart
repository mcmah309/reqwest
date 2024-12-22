import 'dart:convert';
import 'dart:typed_data';

import 'headers.dart';

class Response {
  final Stream<Uint8List> _responseStream;
  final Map<String, List<String>> _headers;

  Response({required Stream<Uint8List> responseStream, required Map<String, List<String>> headers})
      : _responseStream = responseStream,
        _headers = headers;

  /// Get the full response body as Bytes.
  Future<Uint8List> bytes() async {
    final Uint8List bytes =
        await _responseStream.reduce((prev, next) => Uint8List.fromList([...prev, ...next]));
    return bytes;
  }

  /// Convert the response into a Stream of Bytes from the body.
  Stream<Uint8List> stream() {
    return _responseStream;
  }

// bytes_stream
// chunk
// content_length
// cookies
// error_for_status
// error_for_status_ref
// extensions
// extensions_mut
// headers
// headers_mut
// json
// remote_addr
// status

  /// Get the full response text.
  ///
  /// Encoding is determined from the charset parameter of Content-Type header, and defaults to utf-8 if not presented.
  Future<String> text() async {
    final contentTypes = _headers[Headers.CONTENT_TYPE];
    String Function(List<int>)? decoder;
    if (contentTypes == null) {
      decoder = utf8.decode;
    } else {
      for (final contentType in contentTypes) {
        final charset = contentType
            .split(";")
            .map((e) => e.trim())
            .firstWhere((e) => e.startsWith("charset="), orElse: () => "")
            .replaceFirst("charset=", "");
        if (charset.isNotEmpty) {
          final encoding = Encoding.getByName(charset);
          if (encoding != null) {
            decoder = encoding.decode;
            break;
          }
        }
      }
      decoder ??= utf8.decode;
    }

    final Uint8List bytes = await this.bytes();
    return decoder(bytes);
  }

// text_with_charset
// upgrade
// url
// version
}
