part of 'result.dart';

final class Success<T, E> extends Result<T, E> {
  final T value;

  const Success(this.value);
}
