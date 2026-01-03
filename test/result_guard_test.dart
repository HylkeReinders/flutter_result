import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_result/flutter_result.dart';

void main() {
  group('Result.guard', () {
    test('returns Success when action succeeds', () {
      final result = Result.guard<int, String>(() => 123, onError: (e, st) => 'mapped');

      expect(result.isSuccess, isTrue);
      expect(result.value, 123);
    });

    test('returns Failure when action throws and maps error', () {
      final result = Result.guard<int, String>(() => throw FormatException('bad'), onError: (e, st) => 'parse:${e.runtimeType}');

      expect(result.isFailure, isTrue);
      expect(result.error, 'parse:FormatException');
    });

    test('provides a StackTrace to onError', () {
      StackTrace? captured;

      final result = Result.guard<int, String>(
        () => throw StateError('x'),
        onError: (e, st) {
          captured = st;
          return 'mapped';
        },
      );

      expect(result.isFailure, isTrue);
      expect(captured, isNotNull);
    });
  });

  group('Result.guardAsync', () {
    test('returns Success when action succeeds', () async {
      final result = await Result.guardAsync<int, String>(() async => 7, onError: (e, st) => 'mapped');

      expect(result.isSuccess, isTrue);
      expect(result.value, 7);
    });

    test('returns Failure when future completes with error', () async {
      final result = await Result.guardAsync<int, String>(
        () async => throw ArgumentError('no'),
        onError: (e, st) => 'net:${e.runtimeType}',
      );

      expect(result.isFailure, isTrue);
      expect(result.error, 'net:ArgumentError');
    });

    test('returns Failure when action throws synchronously before returning Future', () async {
      Future<int> action() {
        throw Exception('sync throw');
      }

      final result = await Result.guardAsync<int, String>(action, onError: (e, st) => 'unexpected:${e.runtimeType}');

      expect(result.isFailure, isTrue);
      expect(result.error, 'unexpected:_Exception');
    });
  });
}
