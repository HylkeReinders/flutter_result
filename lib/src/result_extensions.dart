import 'result.dart';

extension ResultExtensions<T, E> on Result<T, E> {
  T? get valueOrNull => switch (this) {
    Success<T, E>(value: final v) => v,
    Failure<T, E>() => null,
  };

  E? get errorOrNull => switch (this) {
    Failure<T, E>(error: final e) => e,
    Success<T, E>() => null,
  };

  T getOrElse(T Function(E error) fallback) {
    return switch (this) {
      Success<T, E>(value: final v) => v,
      Failure<T, E>(error: final e) => fallback(e),
    };
  }

  void tap(void Function(T value) onSuccess) {
    if (this is Success<T, E>) {
      onSuccess((this as Success<T, E>).value);
    }
  }

  void tapError(void Function(E error) onFailure) {
    if (this is Failure<T, E>) {
      onFailure((this as Failure<T, E>).error);
    }
  }
}
