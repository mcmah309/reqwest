import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' hide Response;
import 'package:reqwest/reqwest.dart';
import 'package:reqwest/src/body.dart';
import 'package:reqwest/src/error.dart';
import 'package:reqwest/src/method.dart';
import 'package:reqwest/src/response.dart';
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
      // todo headers and such
      final body = request.body;
      if (body != null) {
        switch(body) {
          case StreamingBody():
            break; //todo
          case BytesBody():
            final bytes = body.asBytes();
            httpRequest.write(bytes);
        }
      }
      final HttpClientResponse response = await httpRequest.close();
      final Stream<Uint8List> responseStream = response.cast();
      final Uint8List bytes = await responseStream.reduce((prev, next) => Uint8List.fromList([...prev, ...next]));
      final string = utf8.decode(bytes);
      return Ok(Response());
    } catch (e) {
      return Err(ReqError(e.toString()));
    }
  }
}
