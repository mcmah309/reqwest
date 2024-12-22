part of 'reqwest_base.dart';

class RequestBuilder {
  final Client _client;

  late Body _body;
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

  void basicAuth(String username, [String? password]) {
    final String encoded;
    if (password == null) {
      encoded = base64.encode(utf8.encode("$username:"));
    } else {
      encoded = base64.encode(utf8.encode("$username:$password"));
    }
    _headers[Headers.AUTHORIZATION] = "Basic $encoded";
  }

  void bearerAuth(String token) {
    _headers[Headers.AUTHORIZATION] = "Bearer $token";
  }

  void body(Body body) {
    _body = body;
  }

  Request build() => Request(
      body: _body,
      headers: _headers,
      method: _method,
      timeout: _timeout,
      url: _url,
      version: _version);
// build_split
// fetch_mode_no_cors
// form
// from_parts: Added as constructor
// header
// headers: Added as a field
// json
// multipart
// query
  Future<Result<Response, ReqError>> send() => _client.execute(build());
// timeout
// try_clone
// version
}
