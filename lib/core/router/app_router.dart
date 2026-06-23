import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:location_logger_app/presentation/screens/home_screen.dart';
import 'package:location_logger_app/presentation/screens/logs_screen.dart';
import 'package:location_logger_app/presentation/screens/log_details_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/logs',
      name: 'logs',
      builder: (context, state) => const LogsScreen(),
      routes: [
        GoRoute(
          path: ':sessionId',
          name: 'log-details',
          builder: (context, state) {
            final sessionId = state.pathParameters['sessionId']!;
            return LogDetailsScreen(sessionId: sessionId);
          },
        ),
      ],
    ),
  ],
);
