import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/user_profile.dart';

class AuthState {
  final User? user;
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.profile, this.isLoading = false, this.error});

  AuthState copyWith({
    User? user,
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _initialize();
  }

  final _client = SupabaseConfig.client;

  void _initialize() {
    final session = _client.auth.currentSession;
    if (session != null) {
      state = state.copyWith(user: session.user);
      _loadUserProfile();
    }

    _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        state = state.copyWith(user: session.user);
        _loadUserProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        state = AuthState();
      }
    });
  }

  Future<void> _loadUserProfile() async {
    if (state.user == null) return;

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', state.user!.id)
          .single();

      final profile = UserProfile.fromJson(response);
      state = state.copyWith(profile: profile);
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        state = state.copyWith(user: response.user, isLoading: false);
      }
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'An unexpected error occurred',
        isLoading: false,
      );
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = state.copyWith(user: response.user, isLoading: false);
      }
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'An unexpected error occurred',
        isLoading: false,
      );
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _client.auth.resetPasswordForEmail(email);
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    }
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    if (state.user == null) return;

    try {
      await _client
          .from('profiles')
          .update(updatedProfile.toJson())
          .eq('id', state.user!.id);

      state = state.copyWith(profile: updatedProfile);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update profile');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
