import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' hide Response;
import 'package:reqwest/reqwest.dart';
import 'package:reqwest/src/body.dart';
import 'package:reqwest/src/error.dart';
import 'package:reqwest/src/method.dart';
import 'package:reqwest/src/response.dart';
import 'package:reqwest/src/status_code.dart';
import 'package:reqwest/src/version.dart';
import 'package:rust/rust.dart';

class PlatformClient {
  // Future<Result<Response, ReqError>> execute(Request request) async {
  //   final x = await Dio().get(url.toString());
  //   return Ok(Response());
  // }

  final client = HttpClient();

  Future<Result<Response, ReqError>> execute(Request request) async {
    try {
      final url = Uri.parse(request.url);
      final host = url.host;
      final port = url.port;
      final path = url.path;

      HttpClientRequest httpRequest;
      switch (request.method) {
        case Method.get:
          httpRequest = await client.openUrl('GET', url);
        case Method.post:
          httpRequest = await client.post(host, port, path);
        case Method.put:
          httpRequest = await client.put(host, port, path);
        case Method.delete:
          httpRequest = await client.delete(host, port, path);
        case Method.head:
          httpRequest = await client.head(host, port, path);
        case Method.options:
          httpRequest = await client.openUrl('OPTION', url);
        case Method.connect:
          httpRequest = await client.openUrl('CONNECT', url);
        case Method.patch:
          httpRequest = await client.openUrl('PATCH', url);
        case Method.trace:
          httpRequest = await client.openUrl('TRACE', url);
      }
      request.headers.forEach((key, value) {
        httpRequest.headers.set(key, value);
      });
      // todo headers and such
      final body = request.body;
      if (body != null) {
        switch (body) {
          case StreamingBody():
            break; //todo
          case BytesBody():
            final bytes = body.asBytes();
            httpRequest.write(bytes);
        }
      }
      final HttpClientResponse response = await httpRequest.close();
      final Map<String, List<String>> headers = {};
      response.headers.forEach((name, values) {
        headers[name] = values;
      });
      final int? contentLength = response.contentLength < 0 ? null : response.contentLength;
      final List<Cookie> cookies = response.cookies;
      final int statusCode = response.statusCode;
      assert(statusCode >= 0, 'Status code is negative');
      final StatusCode status = StatusCode(statusCode);
      final Stream<Uint8List> responseStream = response.cast();
      final InternetAddress? remoteAddress = response.connectionInfo?.remoteAddress;
      final Version version = request.version;
      return Ok(Response(
          responseStream: responseStream,
          headers: headers,
          contentLength: contentLength,
          cookies: cookies,
          status: status,
          remoteAddress: remoteAddress,
          url: url,
          version: version));
    } catch (e) {
      return Err(ReqError(e.toString()));
    }
  }
}
