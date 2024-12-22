import 'package:reqwest/reqwest.dart';
import 'package:reqwest/src/error.dart';
import 'package:reqwest/src/response.dart';
import 'package:rust/rust.dart';

class PlatformClient {

  Future<Result<Response, ReqError>> execute(Request request) async {
    throw UnimplementedError();
  }

}