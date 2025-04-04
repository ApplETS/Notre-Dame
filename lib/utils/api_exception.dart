/// Exception that can be thrown by the [SignetsApi]
class ApiException implements Exception {
  final String message;
  final String prefix;
  final String errorCode;

  const ApiException(
      {this.prefix = "", this.message = "", this.errorCode = ""});

  @override
  String toString() {
    return "$prefix ${errorCode.isNotEmpty ? "Code: $errorCode" : ""} Message: $message";
  }
}
