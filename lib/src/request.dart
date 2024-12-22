part of 'reqwest_base.dart';

class Request {
  final Body body;
  final Map<String, String> headers;
  final Method method;
  final Duration? timeout;
  final String url;
  final Version version;

  const Request(
      {this.body = const Body.empty(),
      this.headers = const {},
      required this.method,
      this.timeout,
      required this.url,
      this.version = Version.http_1_1});
}
