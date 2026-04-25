import 'package:go_router/go_router.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/features/auth/screens/login_screen.dart';
import 'package:gestparc/features/eleve/screens/eleve_dashboard_screen.dart';
import 'package:gestparc/features/eleve/screens/notes_screen.dart';
import 'package:gestparc/features/eleve/screens/absences_screen.dart';
import 'package:gestparc/features/eleve/screens/bulletins_screen.dart';
import 'package:gestparc/features/eleve/screens/bulletin_detail_screen.dart';
import 'package:gestparc/features/eleve/screens/emploi_screen.dart';
import 'package:gestparc/features/parent/screens/parent_dashboard_screen.dart';
import 'package:gestparc/features/parent/screens/enfant_detail_screen.dart';
import 'package:gestparc/features/enseignant/screens/enseignant_dashboard_screen.dart';
import 'package:gestparc/features/enseignant/screens/classe_detail_screen.dart';
import 'package:gestparc/features/enseignant/screens/saisie_notes_screen.dart';
import 'package:gestparc/features/enseignant/screens/appel_screen.dart';
import 'package:gestparc/features/enseignant/screens/programmer_evaluation_screen.dart';
import 'package:gestparc/features/enseignant/screens/evaluations_screen.dart';
import 'package:gestparc/features/notifications/screens/notification_screen.dart';
import 'package:gestparc/shared/screens/profile_screen.dart';
import 'package:gestparc/shared/screens/settings_screen.dart';
import 'package:gestparc/shared/widgets/app_main_layout.dart';
import 'package:flutter/material.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final authStatus = authProvider.status;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (authStatus == AuthState.unauthenticated && !isGoingToLogin) {
        return '/login';
      }

      if (authStatus == AuthState.authenticated && isGoingToLogin) {
        if (authProvider.role == 'eleve') {
          return '/eleve';
        } else if (authProvider.role == 'parent') {
          return '/parent';
        } else if (authProvider.role == 'enseignant') {
          return '/enseignant';
        }
        return '/eleve';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Main App Shell Route
      ShellRoute(
        builder: (context, state, child) => AppMainLayout(child: child),
        routes: [
          // Eleve Routes
          GoRoute(
            path: '/eleve',
            name: 'eleve_dashboard',
            builder: (context, state) => const EleveDashboardScreen(),
            routes: [
              GoRoute(
                path: 'notes',
                name: 'eleve_notes',
                builder: (context, state) => const NotesScreen(),
              ),
              GoRoute(
                path: 'absences',
                name: 'eleve_absences',
                builder: (context, state) => const AbsencesScreen(),
              ),
              GoRoute(
                path: 'bulletins',
                name: 'eleve_bulletins',
                builder: (context, state) => const BulletinsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'eleve_bulletin_detail',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return BulletinDetailScreen(bulletinId: id);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'emploi',
                name: 'eleve_emploi',
                builder: (context, state) => const EmploiScreen(),
              ),
            ],
          ),
          
          // Parent Routes
          GoRoute(
            path: '/parent',
            name: 'parent_dashboard',
            builder: (context, state) => const ParentDashboardScreen(),
            routes: [
              GoRoute(
                path: 'enfant/:id',
                name: 'enfant_detail',
                builder: (context, state) => const EnfantDetailScreen(),
              ),
            ],
          ),

          // Enseignant Routes
          GoRoute(
            path: '/enseignant',
            name: 'enseignant_dashboard',
            builder: (context, state) => const EnseignantDashboardScreen(),
            routes: [
              GoRoute(
                path: 'classe/:id',
                name: 'classe_detail',
                builder: (context, state) => const ClasseDetailScreen(),
              ),
              GoRoute(
                path: 'notes/:classeId',
                name: 'saisie_notes',
                builder: (context, state) => const SaisieNotesScreen(),
              ),
              GoRoute(
                path: 'appel/:classeId',
                name: 'faire_appel',
                builder: (context, state) => const AppelScreen(),
              ),
              GoRoute(
                path: 'evaluations/new',
                name: 'programmer_evaluation',
                builder: (context, state) => const ProgrammerEvaluationScreen(),
              ),
              GoRoute(
                path: 'evaluations',
                name: 'liste_evaluations',
                builder: (context, state) => const EvaluationsScreen(),
              ),
            ],
          ),

          // Shared Shell Routes
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
