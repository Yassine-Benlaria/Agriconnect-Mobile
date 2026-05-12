import 'package:agriconnect/core/models/user.dart';
import 'package:agriconnect/core/enums/enums.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  UserRole? get role => user?.role;
  bool get isAuthenticated => status == AuthStatus.authenticated;
}
