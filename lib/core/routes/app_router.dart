import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/features/auth/screens/login_screen.dart';
import 'package:gestparc/features/eleve/screens/eleve_dashboard_screen.dart';
import 'package:gestparc/features/eleve/screens/notes_screen.dart';
import 'package:gestparc/features/eleve/screens/absences_screen.dart';
import 'package:gestparc/features/eleve/screens/bulletins_screen.dart';
import 'package:gestparc/features/eleve/screens/emploi_screen.dart';
import 'package:gestparc/features/parent/screens/parent_dashboard_screen.dart';
import 'package:gestparc/features/parent/screens/enfant_detail_screen.dart';
import 'package:gestparc/features/enseignant/screens/enseignant_dashboard_screen.dart';
import 'package:gestparc/features/enseignant/screens/classe_detail_screen.dart';
import 'package:gestparc/features/enseignant/screens/saisie_notes_screen.dart';
import 'package:gestparc/features/enseignant/screens/appel_screen.dart';

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
        // Redirection based on role
        if (authProvider.role == 'eleve') {
          return '/eleve';
        } else if (authProvider.role == 'parent') {
          return '/parent';
        } else if (authProvider.role == 'enseignant') {
          return '/enseignant';
        }
        return '/eleve'; // Default fallback for other roles
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
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
          ),
          GoRoute(
            path: 'emploi',
            name: 'eleve_emploi',
            builder: (context, state) => const EmploiScreen(),
          ),
        ],
      ),
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
        ],
      ),
    ],
  );
}
