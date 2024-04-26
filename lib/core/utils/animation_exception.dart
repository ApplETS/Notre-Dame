/// Exception that can be thrown by the rive animation service
class AnimationException implements Exception {
  final String _message;
  final String _prefix;
  final Exception? _nestedException;

  const AnimationException(
      {required String prefix,
      required String message,
      Exception? nestedException})
      : _message = message,
        _prefix = prefix,
        _nestedException = nestedException;

  @override
  String toString() {
    return _nestedException == null
        ? "$_prefix - Message: $_message "
        : "$_prefix - Message: $_message - Exception: $_nestedException";
  }
}
