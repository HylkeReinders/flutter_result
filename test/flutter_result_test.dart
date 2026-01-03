import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_result/flutter_result.dart';

void main() {
  group('Result core', () {
    test('Result.success creates a Success', () {
      final result = Result<int, String>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result, isA<Success<int, String>>());
    });

    test('Result.failure creates a Failure', () {
      final result = Result<int, String>.failure('nope');

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result, isA<Failure<int, String>>());
    });

    test('value returns value for Success', () {
      final result = Result<int, String>.success(10);

      expect(result.value, 10);
    });

    test('value throws for Failure', () {
      final result = Result<int, String>.failure('err');

      expect(() => result.value, throwsA(isA<StateError>()));
    });

    test('error returns error for Failure', () {
      final result = Result<int, String>.failure('boom');

      expect(result.error, 'boom');
    });

    test('error throws for Success', () {
      final result = Result<int, String>.success(1);

      expect(() => result.error, throwsA(isA<StateError>()));
    });

    test('fold calls onSuccess for Success', () {
      final result = Result<int, String>.success(5);

      final out = result.fold(onSuccess: (v) => 'ok:$v', onFailure: (e) => 'fail:$e');

      expect(out, 'ok:5');
    });

    test('fold calls onFailure for Failure', () {
      final result = Result<int, String>.failure('bad');

      final out = result.fold(onSuccess: (v) => 'ok:$v', onFailure: (e) => 'fail:$e');

      expect(out, 'fail:bad');
    });

    test('map transforms value for Success', () {
      final result = Result<int, String>.success(2);

      final mapped = result.map((v) => v * 10);

      expect(mapped, isA<Success<int, String>>());
      expect(mapped.value, 20);
    });

    test('map passes Failure through unchanged', () {
      final result = Result<int, String>.failure('x');

      final mapped = result.map((v) => v * 10);

      expect(mapped, isA<Failure<int, String>>());
      expect(mapped.error, 'x');
    });

    test('mapError transforms error for Failure', () {
      final result = Result<int, String>.failure('x');

      final mapped = result.mapError((e) => 'ERR:$e');

      expect(mapped, isA<Failure<int, String>>());
      expect(mapped.error, 'ERR:x');
    });

    test('mapError passes Success through unchanged', () {
      final result = Result<int, String>.success(7);

      final mapped = result.mapError((e) => 'ERR:$e');

      expect(mapped, isA<Success<int, String>>());
      expect(mapped.value, 7);
    });

    test('andThen chains on Success', () {
      final result = Result<int, String>.success(3);

      final chained = result.andThen((v) => Result<String, String>.success('v=$v'));

      expect(chained, isA<Success<String, String>>());
      expect(chained.value, 'v=3');
    });

    test('andThen passes Failure through unchanged', () {
      final result = Result<int, String>.failure('no');

      final chained = result.andThen((v) => Result<String, String>.success('v=$v'));

      expect(chained, isA<Failure<String, String>>());
      expect(chained.error, 'no');
    });

    test('flatMap is an alias for andThen', () {
      final result = Result<int, String>.success(4);

      final chained = result.flatMap((v) => Result<int, String>.success(v + 1));

      expect(chained.value, 5);
    });

    test('recover turns Failure into Success', () {
      final result = Result<int, String>.failure('err');

      final recovered = result.recover((e) => 999);

      expect(recovered, isA<Success<int, String>>());
      expect(recovered.value, 999);
    });

    test('recover leaves Success unchanged', () {
      final result = Result<int, String>.success(1);

      final recovered = result.recover((e) => 999);

      expect(recovered.value, 1);
    });

    test('recoverWith can return a different Result', () {
      final result = Result<int, String>.failure('err');

      final recovered = result.recoverWith((e) => Result<int, String>.failure('still bad'));

      expect(recovered, isA<Failure<int, String>>());
      expect(recovered.error, 'still bad');
    });
  });
}
