abstract class Filter<T> {
  T filterEmittedCache(T items);
  T filterApiCached(T items);
}
