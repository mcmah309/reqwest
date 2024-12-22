import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:reqwest/src/error.dart';
import 'package:reqwest/src/status_code.dart';
import 'package:rust/rust.dart';

import 'headers.dart';
import 'version.dart';

const alreadyConsumedErr = ReqError("Response has already been consumed");

class Response {
  bool _isConsumed = false;
  final Stream<Uint8List> _responseStream;
  final Map<String, List<String>> headers;

  /// The length of the content in bytes, if known. Always positive if not null.
  final int? contentLength;
  final List<Cookie> cookies;
  final StatusCode status;
  final InternetAddress? remoteAddress;
  final Uri url;
  final Version version;

  Response(
      {required Stream<Uint8List> responseStream,
      required this.headers,
      required this.contentLength,
      required this.cookies,
      required this.status,
      required this.remoteAddress,
      required this.url,
      required this.version})
      : _responseStream = responseStream;

  /// Get the full response body as Bytes. Returns an [Err] if the response has already been consumed.
  Future<Result<Uint8List, ReqError>> bytes() async {
    if (_isConsumed) {
      return Err(alreadyConsumedErr);
    }
    _isConsumed = true;
    final Uint8List bytes =
        await _responseStream.reduce((prev, next) => Uint8List.fromList([...prev, ...next]));
    return Ok(bytes);
  }

  /// Convert the response into a Stream of Bytes from the body. Returns an [Err] if the response has already been consumed.
  Result<Stream<Uint8List>, ReqError> bytesStream() {
    if (_isConsumed) {
      return Err(alreadyConsumedErr);
    }
    _isConsumed = true;
    return Ok(_responseStream);
  }

// chunk: Covered by `bytesStream` for Dart impl
// content_length: Added as a property
// cookies: Added as a property

  /// Check if the response status code is a error (any status between 400...599),
  /// if it is, return an [Err] with a [ReqError] containing the status code.
  Result<Response, ReqError> errorForStatus() {
    if (status.value >= 400 && status.value < 600) {
      return Err(ReqError("Request failed with status code $status"));
    }
    return Ok(this);
  }

// error_for_status_ref: Will not do
// extensions: // todo understand this more
// extensions_mut: Will not do
// headers: Added as a property
// headers_mut: Will not do

  Future<Result<Map<String, Object?>, ReqError>> json() async {
    final textResult = await this.text();
    final String text;
    switch (textResult) {
      case Ok(:final v):
        text = v;
      case Err(:final v):
        return Err(v);
    }
    try {
      final Map<String, Object?> json = jsonDecode(text);
      return Ok(json);
    } catch (e) {
      return Err(ReqError(e.toString()));
    }
  }

// remote_addr: Added as property
// status: Added as property

  /// Get the full response text.
  ///
  /// Encoding is determined from the charset parameter of Content-Type header, and defaults to utf-8 if not presented.
  /// Will return [Err] if decoding fails.
  Future<Result<String, ReqError>> text() async {
    final bytesResult = await this.bytes();
    final Uint8List bytes;
    switch (bytesResult) {
      case Ok(:final v):
        bytes = v;
      case Err(:final v):
        return Err(v);
    }
    final contentTypes = headers[Headers.CONTENT_TYPE];
    String Function(List<int>)? decoder;
    if (contentTypes == null) {
      decoder = utf8.decode;
    } else {
      decoder = _getEncodingForContentType(contentTypes);
      decoder ??= utf8.decode;
    }
    try {
      return Ok(decoder(bytes));
    } catch (e) {
      return Err(ReqError(e.toString()));
    }
  }

  /// Get the full response text.
  ///
  /// Encoding is determined from the charset parameter of Content-Type header, and defaults to [defaultEncoding] if not presented.
  /// Will return [Err] if decoding fails or if [defaultEncoding] is invalid.
  Future<Result<String, ReqError>> textWithCharset(String defaultEncoding) async {
    final bytesResult = await this.bytes();
    final Uint8List bytes;
    switch (bytesResult) {
      case Ok(:final v):
        bytes = v;
      case Err(:final v):
        return Err(v);
    }
    final contentTypes = headers[Headers.CONTENT_TYPE];
    String Function(List<int>)? decoder;
    if (contentTypes == null) {
      final encoding = Encoding.getByName(defaultEncoding);
      if (encoding == null) {
        return Err(ReqError("Invalid encoding: $defaultEncoding"));
      } else {
        decoder = encoding.decode;
      }
    } else {
      decoder = _getEncodingForContentType(contentTypes);
      if (decoder == null) {
        final encoding = Encoding.getByName(defaultEncoding);
        if (encoding == null) {
          return Err(ReqError("Invalid encoding: $defaultEncoding"));
        } else {
          decoder = encoding.decode;
        }
      }
    }
    try {
      return Ok(decoder(bytes));
    } catch (e) {
      return Err(ReqError(e.toString()));
    }
  }
// upgrade // todo is this possible?
// url: Added as property
// version: Added as property
}

String Function(List<int>)? _getEncodingForContentType(List<String> contentTypes) {
  for (final contentType in contentTypes) {
    final charset = contentType
        .split(";")
        .map((e) => e.trim())
        .firstWhere((e) => e.startsWith("charset="), orElse: () => "")
        .replaceFirst("charset=", "");
    if (charset.isNotEmpty) {
      final encoding = Encoding.getByName(charset);
      if (encoding != null) {
        return encoding.decode;
      }
    }
  }
  return null;
}
