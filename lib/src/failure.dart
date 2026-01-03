part of 'result.dart';

final class Failure<T, E> extends Result<T, E> {
  final E error;

  const Failure(this.error);
}
