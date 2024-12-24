
part of 'reqwest_base.dart';


/// An asynchronous Client to make Requests with.
///
/// The Client has various configuration values to tweak, but the defaults are set to what is usually
/// the most commonly desired value. To configure a Client, use [Client.builder].
/// The Client holds a connection pool internally, so it is advised that you create one and reuse it.
class Client {

  final Policy policy;

  final PlatformClient _platform_client = PlatformClient();

  factory Client() = Client._;

  Client._({this.policy = const Policy()});

  ClientBuilder builder() => ClientBuilder();

  RequestBuilder delete(String url) => RequestBuilder.fromParts(this, Request(method: Method.delete, url: url));

  Future<Result<Response, ReqError>> execute(Request request) => _platform_client.execute(this, request);

  RequestBuilder get(String url) => RequestBuilder.fromParts(this, Request(method: Method.get, url: url));

  RequestBuilder head(String url) => RequestBuilder.fromParts(this, Request(method: Method.head, url: url));

  RequestBuilder options(String url) => RequestBuilder.fromParts(this, Request(method: Method.options, url: url));

  RequestBuilder patch(String url) => RequestBuilder.fromParts(this, Request(method: Method.patch, url: url));

  RequestBuilder post(String url) => RequestBuilder.fromParts(this, Request(method: Method.post, url: url));

  RequestBuilder put(String url) => RequestBuilder.fromParts(this, Request(method: Method.put, url: url));

  RequestBuilder trace(String url) => RequestBuilder.fromParts(this, Request(method: Method.trace, url: url));

  RequestBuilder request(Method method, String url) => RequestBuilder.fromParts(this, Request(method: method, url: url));
}