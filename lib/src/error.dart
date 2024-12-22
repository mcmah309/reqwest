
class ReqError implements Exception{
  final String message;

  ReqError(this.message);

  @override
  String toString() {
    return "ReqError: $message";
  }
}