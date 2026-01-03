import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_result/flutter_result.dart';

void main() {
  runApp(const MyApp());
}

sealed class AppError {
  const AppError();
  String message();

  const factory AppError.parsing(Object cause) = ParsingError;
  const factory AppError.network(Object cause) = NetworkError;
}

final class ParsingError extends AppError {
  final Object cause;
  const ParsingError(this.cause);

  @override
  String message() => 'Parsing failed: $cause';
}

final class NetworkError extends AppError {
  final Object cause;
  const NetworkError(this.cause);

  @override
  String message() => 'Network failed: $cause';
}

final class User {
  final int id;
  final String name;

  const User({required this.id, required this.name});

  static User fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];

    if (id is! int) throw const FormatException('`id` must be an int');
    if (name is! String || name.isEmpty) throw const FormatException('`name` must be a non-empty string');

    return User(id: id, name: name);
  }
}

/// Simulates an API client that sometimes fails.
class FakeApiClient {
  Future<String> fetchUserJson({required bool shouldFail}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (shouldFail) {
      throw StateError('Simulated network error');
    }

    // Toggle this JSON to test parsing failures:
    // return '{"id":"oops","name":123}';
    return '{"id": 1, "name": "Hylke"}';
  }
}

class UserRepository {
  final FakeApiClient apiClient;
  const UserRepository(this.apiClient);

  Future<Result<User, AppError>> fetchUser({required bool shouldFailNetwork}) async {
    final jsonStringResult = await Result.guardAsync<String, AppError>(
      () => apiClient.fetchUserJson(shouldFail: shouldFailNetwork),
      onError: (e, st) => AppError.network(e),
    );

    return jsonStringResult.andThen((jsonString) {
      return Result.guard<User, AppError>(() {
        final decoded = jsonDecode(jsonString);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Expected a JSON object');
        }
        return User.fromJson(decoded);
      }, onError: (e, st) => AppError.parsing(e));
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _repo = UserRepository(FakeApiClient());

  bool _simulateNetworkFail = false;
  bool _loading = false;

  Result<User, AppError>? _result;

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _result = null;
    });

    final res = await _repo.fetchUser(shouldFailNetwork: _simulateNetworkFail);

    setState(() {
      _result = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_result example')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                title: const Text('Simulate network failure'),
                subtitle: const Text('Throws inside the async boundary and gets mapped via Result.guardAsync'),
                value: _simulateNetworkFail,
                onChanged: _loading
                    ? null
                    : (v) {
                        setState(() => _simulateNetworkFail = v);
                      },
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _loading ? null : _loadUser, child: _loading ? const Text('Loading...') : const Text('Fetch user')),
              const SizedBox(height: 24),
              const Text('Result output', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(padding: const EdgeInsets.all(12), child: _buildResultView(result)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultView(Result<User, AppError>? result) {
    if (result == null) {
      return const Center(child: Text('Press "Fetch user" to see Success/Failure.'));
    }

    return result.fold(
      onSuccess: (user) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✅ Success', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('id: ${user.id}'),
          Text('name: ${user.name}'),
          const SizedBox(height: 16),
          const Text('How it got here:'),
          const SizedBox(height: 6),
          const Text(
            '- Result.guardAsync wrapped the API call\n'
            '- Result.guard wrapped JSON decode + parsing\n'
            '- andThen chained the steps without nesting',
          ),
        ],
      ),
      onFailure: (error) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('❌ Failure', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(error.message()),
          const SizedBox(height: 16),
          const Text('How to reproduce:'),
          const SizedBox(height: 6),
          const Text(
            '- Toggle "Simulate network failure" to trigger a network error\n'
            '- Or change the JSON in FakeApiClient to invalid types to trigger parsing',
          ),
        ],
      ),
    );
  }
}
