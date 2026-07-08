import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/chat/presentation/pages/home_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/call/presentation/pages/audio_call_page.dart';
import '../../features/call/presentation/pages/video_call_page.dart';
import '../../features/chat/presentation/pages/users_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) => ChatPage(chatId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/audio_call/:id',
        builder: (context, state) => AudioCallPage(chatId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/video_call/:id',
        builder: (context, state) => VideoCallPage(chatId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UsersPage(),
      ),
    ],
  );
}

