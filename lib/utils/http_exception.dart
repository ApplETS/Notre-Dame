/// Exception for the different Rest API we can call
class HttpException implements Exception {
  final String _message;
  final String _prefix;
  final int _code;

  HttpException({String prefix = "", int code = 404, String message = ""})
      : _message = message,
        _code = code,
        _prefix = prefix;

  int get code {
    return _code;
  }

  @override
  String toString() {
    return "$_prefix - $_code $_message";
  }
}
