import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';

class AppMainLayout extends StatelessWidget {
  final Widget child;

  const AppMainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.role ?? 'eleve';
    
    // Base path for the current role
    final String baseRoute = '/$role';
    
    // Determine current index based on location
    int currentIndex = 0;
    if (location == baseRoute) {
      currentIndex = 0;
    } else if (location.startsWith('/notifications')) {
      currentIndex = 1;
    } else if (location.startsWith('/profile')) {
      currentIndex = 2;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomBar(context, currentIndex, baseRoute),
    );
  }

  Widget _buildBottomBar(BuildContext context, int currentIndex, String baseRoute) {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_rounded, 'Accueil', currentIndex == 0, () => context.go(baseRoute)),
          _buildNavItem(context, Icons.chat_bubble_outline_rounded, 'Messagerie', currentIndex == 1, () => context.push('/notifications')),
          _buildNavItem(context, Icons.person_outline_rounded, 'Profil', currentIndex == 2, () => context.push('/profile')),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF3B82F6) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.white60,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isActive ? Colors.white : Colors.white60,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
