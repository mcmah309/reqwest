
enum Method {
  get("GET"),
  post("POST"),
  put("PUT"),
  delete("DELETE"),
  head("HEAD"),
  options("OPTIONS"),
  connect("CONNECT"),
  patch("PATCH"),
  trace("TRACE");

  final String _method;

  const Method(this._method);

  @override
  String toString() => _method;
}