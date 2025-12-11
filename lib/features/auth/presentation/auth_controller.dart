import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

/// Auth state model
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

/// Auth controller using AsyncNotifier for managing authentication state
class AuthController extends AsyncNotifier<User?> {
  late final AuthRepository _authRepository;

  @override
  Future<User?> build() async {
    _authRepository = ref.read(authRepositoryProvider);

    // Listen to auth state changes
    _authRepository.authStateChanges.listen((authState) {
      state = AsyncData(authState.session?.user);
    });

    return _authRepository.currentUser;
  }

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );

      state = AsyncData(response.user);
    } on AuthException catch (e) {
      state = AsyncError(e.message, StackTrace.current);
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
      );

      state = AsyncData(response.user);
    } on AuthException catch (e) {
      state = AsyncError(e.message, StackTrace.current);
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    state = const AsyncLoading();

    try {
      await _authRepository.signOut();
      state = const AsyncData(null);
    } on AuthException catch (e) {
      state = AsyncError(e.message, StackTrace.current);
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _authRepository.resetPassword(email: email);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Clear error state
  void clearError() {
    if (state.hasError) {
      state = AsyncData(state.valueOrNull);
    }
  }
}

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider for AuthController
final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  () => AuthController(),
);

/// Provider for current user state
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authControllerProvider).valueOrNull;
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Provider for auth loading state
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isLoading;
});

/// Provider for auth error state
final authErrorProvider = Provider<String?>((ref) {
  final asyncValue = ref.watch(authControllerProvider);
  return asyncValue.hasError ? asyncValue.error.toString() : null;
});