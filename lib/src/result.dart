// lib/src/result.dart
//
// Core Result contract + essential behavior.
// This file is completely context free: no adapters, no HTTP/Dio, no AppError opinions.
// no logging, no IO.
//
// This file expects two part files next to it:
// - success.dart (part of 'result.dart')
// - failure.dart (part of 'result.dart')

part 'success.dart';
part 'failure.dart';

sealed class Result<T, E> {
  const Result();

  const factory Result.success(T value) = Success<T, E>;
  const factory Result.failure(E error) = Failure<T, E>;

  bool get isSuccess => switch (this) {
    Success<T, E>() => true,
    Failure<T, E>() => false,
  };

  bool get isFailure => !isSuccess;

  T get value => switch (this) {
    Success<T, E>(value: final value) => value,
    Failure<T, E>() => throw StateError("Tried to access `value` on a Failure result."),
  };

  E get error => switch (this) {
    Failure<T, E>(error: final error) => error,
    Success<T, E>() => throw StateError("Tried to access `error` on a Success result."),
  };

  /// The primary consumption API.
  /// Forces explicit handling of both success and failure paths.
  R fold<R>({required R Function(T value) onSuccess, required R Function(E error) onFailure}) {
    return switch (this) {
      Success<T, E>(value: final v) => onSuccess(v),
      Failure<T, E>(error: final e) => onFailure(e),
    };
  }

  /// Transforms the success value. Failures pass through unchanged.
  Result<R, E> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T, E>(value: final v) => Result<R, E>.success(transform(v)),
      Failure<T, E>(error: final e) => Result<R, E>.failure(e),
    };
  }

  /// Transforms the error value. Success passes through unchanged.
  Result<T, F> mapError<F>(F Function(E error) transform) {
    return switch (this) {
      Success<T, E>(value: final v) => Result<T, F>.success(v),
      Failure<T, E>(error: final e) => Result<T, F>.failure(transform(e)),
    };
  }

  /// Chains operations that can also fail, without nesting.
  ///
  /// Example:
  ///   fetchUser()
  ///     .andThen(validateUser)
  ///     .andThen(saveUser);
  Result<R, E> andThen<R>(Result<R, E> Function(T value) next) {
    return switch (this) {
      Success<T, E>(value: final v) => next(v),
      Failure<T, E>(error: final e) => Result<R, E>.failure(e),
    };
  }

  /// Alias for [andThen] for teams that prefer "flatMap" naming.
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) next) => andThen(next);

  /// Turns a Failure into a Success by providing a fallback value.
  /// Useful at boundaries (e.g. UI) where you want to recover.
  Result<T, E> recover(T Function(E error) fallback) {
    return switch (this) {
      Success<T, E>() => this,
      Failure<T, E>(error: final e) => Result<T, E>.success(fallback(e)),
    };
  }

  /// Same as [recover], but allows the recovery itself to fail.
  Result<T, E> recoverWith(Result<T, E> Function(E error) fallback) {
    return switch (this) {
      Success<T, E>() => this,
      Failure<T, E>(error: final e) => fallback(e),
    };
  }

  static Result<T, E> guard<T, E>(T Function() action, {required E Function(Object error, StackTrace stackTrace) onError}) {
    try {
      final value = action();
      return Result<T, E>.success(value);
    } catch (error, stackTrace) {
      return Result<T, E>.failure(onError(error, stackTrace));
    }
  }

  static Future<Result<T, E>> guardAsync<T, E>(
    Future<T> Function() action, {
    required E Function(Object error, StackTrace stackTrace) onError,
  }) async {
    try {
      final value = await action();
      return Result<T, E>.success(value);
    } catch (error, stackTrace) {
      return Result<T, E>.failure(onError(error, stackTrace));
    }
  }
}
