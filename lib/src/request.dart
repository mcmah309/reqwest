part of 'reqwest_base.dart';

class Request {
  final Body? body;
  /// The headers of the request. This is an immutable map.
  final Map<String, String> headers;
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
}
