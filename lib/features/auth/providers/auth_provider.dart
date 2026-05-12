import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;
  final SecureStorageService _storage;

  AuthNotifier(this._api, this._storage) : super(const AuthState()) {
    _checkAuth();
  }

  /// On startup, check if a valid token exists and fetch the profile.
  Future<void> _checkAuth() async {
    final token = await _storage.getAccessToken();
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _api.getMe();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(error: null);
    try {
      final tokens = await _api.login(email, password);
      await _storage.saveTokens(
        accessToken: tokens['accessToken']!,
        refreshToken: tokens['refreshToken']!,
      );
      final user = await _api.getMe();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on Exception catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
      rethrow;
    }
  }

  Future<void> registerBuyer(Map<String, dynamic> data) async {
    await _register(() => _api.registerBuyer(data));
  }

  Future<void> registerFarmer(Map<String, dynamic> data) async {
    await _register(() => _api.registerFarmer(data));
  }

  Future<void> registerDeliverer(Map<String, dynamic> data) async {
    await _register(() => _api.registerDeliverer(data));
  }

  Future<void> _register(Future<Map<String, String>> Function() fn) async {
    try {
      final tokens = await fn();
      await _storage.saveTokens(
        accessToken: tokens['accessToken']!,
        refreshToken: tokens['refreshToken']!,
      );
      final user = await _api.getMe();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on Exception catch (e) {
      state = state.copyWith(error: _extractError(e));
      rethrow;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    await _storage.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshUser() async {
    try {
      final user = await _api.getMe();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  String _extractError(Exception e) {
    final str = e.toString();
    // Try to extract the "message" field from the API error response
    final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(str);
    if (match != null) return match.group(1)!;
    return 'An error occurred. Please try again.';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final api = ref.watch(apiServiceProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthNotifier(api, storage);
});
