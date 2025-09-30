import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/doctors/doctor_list_screen.dart';
import '../screens/doctors/doctor_detail_screen.dart';
import '../screens/doctors/book_appointment_screen.dart';
import '../screens/appointments/appointment_list_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/articles/article_list_screen.dart';
import '../screens/articles/article_detail_screen.dart';
import '../models/doctor.dart';
import '../models/article.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: authState.user != null ? '/home' : '/onboarding',
    redirect: (context, state) {
      final isAuthenticated = authState.user != null;
      final isOnAuthPage = [
        '/login',
        '/signup',
        '/forgot-password',
        '/onboarding',
      ].contains(state.matchedLocation);

      if (!isAuthenticated && !isOnAuthPage) {
        return '/onboarding';
      }

      if (isAuthenticated && isOnAuthPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignupScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => ForgotPasswordScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
      GoRoute(
        path: '/doctors',
        builder: (context, state) => DoctorListScreen(),
      ),
      GoRoute(
        path: '/doctor-detail',
        builder: (context, state) {
          final doctor = state.extra as Doctor;
          return DoctorDetailScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/book-appointment',
        builder: (context, state) {
          final doctor = state.extra as Doctor;
          return BookAppointmentScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/appointments',
        builder: (context, state) => AppointmentListScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          return ChatScreen(
            doctorId: params['doctorId'],
            doctorName: params['doctorName'],
          );
        },
      ),
      GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => EditProfileScreen(),
      ),
      GoRoute(
        path: '/articles',
        builder: (context, state) => ArticleListScreen(),
      ),
      GoRoute(
        path: '/article-detail',
        builder: (context, state) {
          final article = state.extra as Article;
          return ArticleDetailScreen(article: article);
        },
      ),
    ],
  );
});
