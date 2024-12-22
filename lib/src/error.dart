
class ReqError implements Exception{
  final String message;

  const ReqError(this.message);

  @override
  String toString() {
    return "ReqError: $message";
  }
}