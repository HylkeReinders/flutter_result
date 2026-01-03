# flutter_result

Explicit, readable result handling for Dart & Flutter.

This package provides a small Result<T, E> abstraction to model success and failure explicitly, without relying on exceptions, nulls, or deeply nested conditionals.

It is designed for production codebases where clarity and long-term maintainability matter more than clever abstractions.

---

## The problem

In many Dart and Flutter codebases, failure is handled using:
• try/catch blocks scattered across layers
• nullable return values with implicit meaning
• exceptions used for control flow
• deeply nested if statements

These approaches tend to:
• hide failure paths
• make flows harder to read
• complicate testing
• break down as codebases grow

This package exists to make success and failure explicit, predictable, and readable.

---

## Design goals
• Explicit control flow over hidden magic
• Readable code that still makes sense a year later
• Small, focused API surface
• No dependency on functional programming frameworks
• Easy integration with Bloc and layered architectures

---

## Non-goals
• This is not a full functional programming library
• This does not try to replace exceptions everywhere
• This does not introduce code generation
• This is not designed to be “clever”

If you are looking for advanced FP constructs or heavy abstractions, this package is likely not a good fit.

---

## Core concept

A Result<T, E> represents either:
- a successful value of type T
- a failure of type E

Both cases must be handled explicitly.

Example:

```dart
final Result<User, AppError> result = await repository.fetchUser();

return result.fold(
    onSuccess: (user) => UserLoaded(user),
    onFailure: (error) => UserError(error),
);
```

There is no implicit success, no silent failure, and no nested conditionals.

---

## Basic usage

Creating results:

```dart
Success<User, AppError>(user);

Failure<User, AppError>(AppError.network());
```

Mapping values:

```dart
result.map((user) => user.name);
```

Mapping errors:

```dart
result.mapError((error) => error.toUiError());
```

Chaining operations:

```dart
repository
    .fetchUser()
    .andThen(validateUser)
    .andThen(saveUser);
```

---

## Guarding exceptions

In production code, exceptions still happen.
This package allows you to contain them at the boundary.

Synchronous:

```dart
final result = Result.guard(
    () => parseUser(json),
    onError: (e, stackTrace) => AppError.parsing(e),
);
```

Asynchronous:

```dart
final result = await Result.guardAsync(
    () => apiClient.fetchUser(),
    onError: (e, stackTrace) => AppError.network(e),
);
```

After this point, your application logic no longer needs try/catch.

---

## Error modeling

Instead of using strings or generic exceptions, this package encourages explicit error modeling.

Example error hierarchy:

```dart
sealed class AppError;

final class NetworkError extends AppError {
    final int? statusCode;
}

final class UnauthorizedError extends AppError {}

final class ParsingError extends AppError {
    final Object cause;
}

final class UnexpectedError extends AppError {
    final Object cause;
    final StackTrace? stackTrace;
}
```

This keeps error handling predictable and testable across layers.

---

## Integration with Bloc

Result works naturally with Bloc-style state machines.

Typical flow:
• Repository returns Result
• Bloc folds Result into states
• UI reacts to explicit states

Example:
```dart
final result = await repository.fetchUser();

emit(
    result.fold(
        onSuccess: (user) => UserLoaded(user),
        onFailure: (error) => UserError(error),
    ),
);
```
This avoids implicit branching and keeps state transitions explicit.

---

## Adapters (optional)

This package includes optional adapters to map HTTP responses into Result types.

For example:
• HTTP 200 → Success
• HTTP 401 → UnauthorizedError
• Invalid JSON → ParsingError
• Network failure → NetworkError

Adapters are intentionally thin and opinionated.
They exist to demonstrate error boundaries, not to abstract HTTP clients.

---

## Trade-offs

Using Result introduces:
• slightly more boilerplate
• more explicit code paths

In return, you get:
• clearer control flow
• easier testing
• fewer hidden edge cases
• code that scales better over time

This is a deliberate trade-off.

---

## When NOT to use this
• Very small scripts or throwaway prototypes
• Codebases where exceptions are already strictly managed and documented
• Teams that prefer implicit control flow

---

## Philosophy

This package favors:
• explicit over implicit
• readable over clever
• boring over surprising

If something feels verbose, it is usually because the complexity already existed — this package simply makes it visible.

---

## Status

This package is actively being developed and refined based on real-world usage.

Breaking changes will be avoided where possible and documented clearly when unavoidable.

---

## License

MIT
