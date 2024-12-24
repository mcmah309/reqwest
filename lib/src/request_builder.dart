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

  /// Enable HTTP basic authentication.
  void basicAuth(String username, [String? password]) {
    final String encoded;
    if (password == null) {
      encoded = base64.encode(utf8.encode("$username:"));
    } else {
      encoded = base64.encode(utf8.encode("$username:$password"));
    }
    _headerAdd(Headers.AUTHORIZATION, "Basic $encoded");
  }

  /// Enable HTTP bearer authentication.
  void bearerAuth(String token) {
    _headerAdd(Headers.AUTHORIZATION, "Bearer $token");
  }

  /// Set the request body.
  void body(Body body) {
    _body = body;
  }

  /// Build a Request, which can be inspected, modified and executed with [Client.execute].
  Request build() => Request(
      body: _body,
      headers: Map.unmodifiable(_headers),
      method: _method,
      timeout: _timeout,
      url: _url,
      version: _version);

  /// Build a Request, which can be inspected, modified and executed with [Client.execute].
  /// But also returns the client used to build the request.
  (Client, Request) buildSplit() => (_client, build());

// fetch_mode_no_cors // todo - web mode only

  /// Send a form body.
  /// 
  /// Sets the body to the url encoded serialization of the passed value, and also sets the Content-Type: application/x-www-form-urlencoded header.
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

  /// Send a JSON body.
  void json(Map<String, Object?> json) {
    _headerAdd(Headers.CONTENT_TYPE, "application/json");
    _body = json.toBody();
  }

  /// Sets the body to a multipart/form-data body.
  /// 
  /// In additional the request’s body, the Content-Type and Content-Length fields are appropriately set.
  void multipart(Form form) {
    // todo
  }

  /// Modifies the URL of this request, adding the parameters provided. This method appends and does not overwrite. 
  // void query(Map<String,String> newParams) {
  //   final url = Uri.tryParse(_url); // todo should be start with a uri from the get go? Maybe for ergonomics we dont add these all together until send time
  //   url.queryParameters // todo this is unmofiable, how to handle?
  // }

  /// Constructs the Request and sends it to the target URL, returning a future Response.
  Future<Result<Response, ReqError>> send() => _client.execute(build());

  /// Enables a request timeout.
  /// 
  /// The timeout is applied from when the request starts connecting until the response body has finished.
  /// It affects only this request and overrides the timeout configured using [ClientBuilder.timeout].
  void timeout(Duration timeout) {
    _timeout = timeout;
  }

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

  /// Set HTTP version
  void version(Version version) {
    _version = version;
  }

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
