# Changelog

## 0.0.1

Initial release.

### Added
- Core `Result<T, E>` abstraction to explicitly model success and failure
- `Success` and `Failure` implementations with a sealed Result contract
- Core APIs:
  - `fold`
  - `map`
  - `mapError`
  - `andThen` / `flatMap`
  - `recover` / `recoverWith`
- Explicit fail-fast accessors (`value`, `error`)
- `Result.guard` and `Result.guardAsync` for containing exceptions at system boundaries
- DX helpers via extensions:
  - `valueOrNull`
  - `errorOrNull`
  - `getOrElse`
  - `tap` / `tapError`
- `AsyncResult<T, E>` typedef for cleaner async signatures
- Example Flutter app demonstrating:
  - boundary exception handling
  - chaining without nested conditionals
  - explicit success and failure flows

### Notes
This release focuses on clarity, explicit control flow, and production-minded defaults.
The API surface is intentionally small and opinionated.