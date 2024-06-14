/// Exception that can be thrown by the [CacheManager]
class CacheException implements Exception {
  final String _message;
  final String _prefix;

  const CacheException({required String prefix, required String message})
      : _message = message,
        _prefix = prefix;

  @override
  String toString() {
    return "$_prefix - Message: $_message";
  }
}
