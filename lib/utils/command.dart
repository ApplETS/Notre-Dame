abstract class Command<T> {
  Future<T> execute();
}
