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
      // FIXED: Changed from 'profiles' to 'user_profiles'
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', state.user!.id)
          .maybeSingle(); // Changed to maybeSingle() to avoid errors if profile doesn't exist

      if (response != null) {
        final profile = UserProfile.fromJson(response);
        state = state.copyWith(profile: profile);
      } else {
        // If profile doesn't exist, create it
        print('Profile not found, creating one...');
        await _createUserProfile(state.user!);
      }
    } catch (e) {
      print('Error loading profile: $e');
      // Try to create profile if it doesn't exist
      try {
        await _createUserProfile(state.user!);
      } catch (createError) {
        print('Error creating profile: $createError');
      }
    }
  }

  // NEW: Function to create user profile if it doesn't exist
  Future<void> _createUserProfile(User user) async {
    try {
      final profileData = {
        'id': user.id,
        'email': user.email ?? '',
        'name':
            user.userMetadata?['full_name'] ??
            user.email?.split('@')[0] ??
            'User',
        'phone': user.phone ?? '',
        'profile_image': '',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('user_profiles').upsert(profileData);

      // Reload the profile
      await _loadUserProfile();

      print('Profile created successfully');
    } catch (e) {
      print('Error creating profile: $e');
      rethrow;
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
        // Create user profile immediately after signup
        await _createUserProfile(response.user!);
        state = state.copyWith(user: response.user, isLoading: false);
      }
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
      print('Auth error: ${e.message}');
    } catch (e) {
      state = state.copyWith(
        error: 'An unexpected error occurred: $e',
        isLoading: false,
      );
      print('Signup error: $e');
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
        // Load or create profile after successful login
        await _loadUserProfile();
      }
    } on AuthException catch (e) {
      // Provide more user-friendly error messages
      String errorMessage = e.message;
      if (errorMessage.toLowerCase().contains('invalid login credentials')) {
        errorMessage = 'Invalid email or password. Please try again.';
      } else if (errorMessage.toLowerCase().contains('email not confirmed')) {
        errorMessage =
            'Please verify your email before signing in. Check your inbox for the confirmation link.';
      }

      state = state.copyWith(error: errorMessage, isLoading: false);
      print('Auth error: ${e.message}');
    } catch (e) {
      state = state.copyWith(
        error: 'An unexpected error occurred: $e',
        isLoading: false,
      );
      print('Login error: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      state = AuthState(); // Reset state
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _client.auth.resetPasswordForEmail(email);
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to send reset email',
        isLoading: false,
      );
    }
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    if (state.user == null) return;

    try {
      // FIXED: Changed from 'profiles' to 'user_profiles'
      await _client
          .from('user_profiles')
          .update(updatedProfile.toJson())
          .eq('id', state.user!.id);

      state = state.copyWith(profile: updatedProfile);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update profile: $e');
      print('Update profile error: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
