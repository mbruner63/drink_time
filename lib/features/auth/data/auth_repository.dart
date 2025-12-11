import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for handling authentication operations with Supabase
class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in');
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign out');
    }
  }

  /// Reset password via email
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during password reset');
    }
  }

  /// Check if user is currently signed in
  bool get isSignedIn => currentUser != null;

  /// Get current user ID
  String? get userId => currentUser?.id;

  /// Get current user email
  String? get userEmail => currentUser?.email;
}