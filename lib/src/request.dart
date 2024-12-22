part of 'reqwest_base.dart';

/// A request which can be executed with [Client]
class Request {
  final Body? body;

  /// The headers of the request. This is an immutable map.
  final Map<String, List<String>> headers;
  final Method method;
  final Duration? timeout;
  final String url;
  final Version version;

  const Request(
      {this.body,
      this.headers = const {},
      required this.method,
      this.timeout,
      required this.url,
      this.version = Version.http_1_1});

  /// Tries to clone the request. Returns null if the body is a stream.
  Request? tryClone() {
    switch (body) {
      case StreamingBody():
        return null;
      case BytesBody():
      case Null():
        return Request(
            body: body,
            headers: Map.from(headers),
            method: method,
            timeout: timeout,
            url: url,
            version: version);
    }
  }
}
