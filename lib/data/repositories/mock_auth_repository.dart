import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_repository.dart';

// Simple mock user that implements the necessary fields
// We can't easily extend User because it has a lot of members. 
// Instead, we will return null or a simple object if we can, BUT the app expects User?
// Since we can't instantiate User, we might need to rely on the fact that we can implement it 
// but it has MANY methods.
// A better approach for this simple app might be to Cast or just use null if the app handles it, 
// OR simpler: use a real UserCredential if we can, but we can't.

// revised strategy: The app only uses `signInAnonymously` and `authStateChanges`.
// It generally doesn't inspect the User object too deeply in the simple dashboard/student screen 
// (unless it checks uid).
// Let's create a minimal implementation.

class SimpleMockUser implements User {
  @override
  String get uid => 'mock_user_123';

  @override
  bool get isAnonymous => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SimpleMockUserCredential implements UserCredential {
  @override
  User? get user => SimpleMockUser();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthRepository implements AuthRepository {
  // ignore: close_sinks
  final _controller = StreamController<User?>.broadcast();
  User? _currentUser;

  MockAuthRepository() {
    _currentUser = SimpleMockUser();
    _controller.add(_currentUser);
  }

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  Future<UserCredential> signInAnonymously() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = SimpleMockUser();
    _controller.add(_currentUser);
    return SimpleMockUserCredential();
  }

  @override
  User? get currentUser => _currentUser;
}
