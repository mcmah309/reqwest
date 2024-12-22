part of 'reqwest_base.dart';

/// A builder to construct the properties of a Request.
///
/// To construct a RequestBuilder, use [RequestBuilder.fromParts] or methods from a [Client]
/// such as [Client.get], [Client.post], etc.
class RequestBuilder {
  final Client _client;

  late Body? _body;
  late Map<String, List<String>> _headers;
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
      required Map<String, List<String>> headers,
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

  void basicAuth(String username, [String? password]) {
    final String encoded;
    if (password == null) {
      encoded = base64.encode(utf8.encode("$username:"));
    } else {
      encoded = base64.encode(utf8.encode("$username:$password"));
    }
    _headerAdd(Headers.AUTHORIZATION, "Basic $encoded");
  }

  void bearerAuth(String token) {
    _headerAdd(Headers.AUTHORIZATION, "Bearer $token");
  }

  void body(Body body) {
    _body = body;
  }

  Request build() => Request(
      body: _body,
      headers: Map.unmodifiable(_headers),
      method: _method,
      timeout: _timeout,
      url: _url,
      version: _version);

  (Client, Request) buildSplit() => (_client, build());

// fetch_mode_no_cors // todo - web mode only

  void form(Map<String, String> data) {
    _headerAdd(Headers.CONTENT_TYPE, "application/x-www-form-urlencoded");
    final queryString = Uri(queryParameters: data).query;
    _body = queryString.toBody();
  }

// from_parts: Added as constructor

  /// Adds a header to the request. Headers are merged with existing ones - does not overwrite existing headers.
  void header(String key, String value) {
    _headerAdd(key, value);
  }

  /// Adds all headers to the request. Headers are merged with existing ones - does not overwrite existing headers.
  void headers(Map<String, List<String>> headers) {
    _headerAddAll(headers);
  }

  void json(Map<String, Object?> json) {
    _headerAdd(Headers.CONTENT_TYPE, "application/json");
    _body = json.toBody();
  }

// multipart // todo
// query //todo
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

  void _headerAdd(String key, String value) {
    final headerValues = (_headers[key] ??= <String>[]);
    headerValues.add(value);
  }

  void _headerAddAll(Map<String, List<String>> headers) {
    headers.forEach((key, values) {
      final headerValues = _headers[key] ??= <String>[];
      headerValues.addAll(values);
    });
  }
}
