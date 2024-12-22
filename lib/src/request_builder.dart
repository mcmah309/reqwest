part of 'reqwest_base.dart';

/// A reference to the [build] and [send] methods so a request can be configured and sent
/// in one shot
/// ```dart
/// final client = Client();
/// final result = await client.post(...)
///   ..header("User-Agent", "reqwest-dart")
///   ..header("Content-Type", "application/json")
///   ..header("Accept", "text/html").
///   ..body(Body.wrap("Hello, world!".asBytes)).send();
/// ```
abstract class RequestBuilderRef {
  Request build();

  Future<Result<Response, ReqError>> send();
}

class RequestBuilder implements RequestBuilderRef {
  final Client _client;

  late Body? _body;
  late Map<String, String> _headers;
  late Method _method;
  late Duration? _timeout;
  late String _url;
  late Version _version;

  RequestBuilder.fromParts(this._client, Request request) {
    _body = request.body;
    _headers = Map.from(request.headers);
    _method = request.method;
    _timeout = request.timeout;
    _url = request.url;
    _version = request.version;
  }

  RequestBuilder._clone(
      {required Client client,
      required Body? body,
      required Map<String, String> headers,
      required Method method,
      required Duration? timeout,
      required String url,
      required Version version})
      : _client = client,
        _body = body,
        _headers = headers,
        _method = method,
        _timeout = timeout,
        _url = url,
        _version = version;

  RequestBuilderRef basicAuth(String username, [String? password]) {
    final String encoded;
    if (password == null) {
      encoded = base64.encode(utf8.encode("$username:"));
    } else {
      encoded = base64.encode(utf8.encode("$username:$password"));
    }
    _headers[Headers.AUTHORIZATION] = "Basic $encoded";
    return this;
  }

  RequestBuilderRef bearerAuth(String token) {
    _headers[Headers.AUTHORIZATION] = "Bearer $token";
    return this;
  }

  RequestBuilderRef body(Body body) {
    _body = body;
    return this;
  }

  @override
  Request build() => Request(
      body: _body,
      headers: Map.unmodifiable(_headers),
      method: _method,
      timeout: _timeout,
      url: _url,
      version: _version);
// build_split: // todo
// fetch_mode_no_cors // todo - web mode only
// form // todo
// from_parts: Added as constructor

  RequestBuilderRef header(String key, String value) {
    _headers[key] = value;
    return this;
  }

  RequestBuilderRef headers(Map<String, String> headers) {
    _headers = headers;
    return this;
  }

  RequestBuilderRef json(Map<String, Object?> json) {
    _headers[Headers.CONTENT_TYPE] = "application/json";
    _body = json.toBody();
    return this;
  }

// multipart // todo
// query //todo
  @override
  Future<Result<Response, ReqError>> send() => _client.execute(build());
// timeout //todo

  /// Tries to clone the request builder. Returns null if the body is a stream.
  RequestBuilder? tryClone() {
    switch (_body) {
      case StreamingBody():
        return null;
      case BytesBody():
      case Null():
        return RequestBuilder._clone(
            client: _client,
            body: _body,
            headers: _headers,
            method: _method,
            timeout: _timeout,
            url: _url,
            version: _version);
    }
  }
// version // todo
}
