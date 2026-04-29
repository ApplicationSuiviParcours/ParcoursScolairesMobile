import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final bool isCenter;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.isCenter = false,
  });
}

class AppMainLayout extends StatelessWidget {
  final Widget child;

  const AppMainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.role ?? 'eleve';
    final String baseRoute = '/$role';

    List<NavItem> items = [];
    if (role == 'eleve') {
      items = [
        NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Accueil', route: baseRoute),
        NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'Notes', route: '$baseRoute/notes'),
        NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Messagerie', route: '/notifications', isCenter: true),
        NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: 'Emploi du temps', route: '$baseRoute/emploi'),
        NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil', route: '/profile'),
      ];
    } else {
      items = [
        NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Accueil', route: baseRoute),
        NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'Enfants', route: baseRoute),
        NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Messagerie', route: '/notifications', isCenter: true),
        NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: 'Emploi du temps', route: baseRoute),
        NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil', route: '/profile'),
      ];
    }

    int currentIndex = items.indexWhere((item) => location == item.route);
    if (currentIndex == -1 && location.startsWith(baseRoute)) currentIndex = 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: child,
      bottomNavigationBar: _buildBottomBar(context, items, currentIndex, isDark),
    );
  }

  Widget _buildBottomBar(BuildContext context, List<NavItem> items, int currentIndex, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isActive = currentIndex == index;

            if (item.isCenter) {
              return GestureDetector(
                onTap: () => context.push(item.route),
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              );
            }

            return GestureDetector(
              onTap: () {
                if (item.route.startsWith('/')) {
                   if (item.route == '/notifications' || item.route == '/profile') {
                      context.push(item.route);
                   } else {
                      context.go(item.route);
                   }
                }
              },
              child: Container(
                color: Colors.transparent, // expand tap area
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: isActive ? const Color(0xFF3B82F6) : (isDark ? Colors.grey[500] : Colors.grey[400]),
                      size: 26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: GoogleFonts.inter(
                        color: isActive ? const Color(0xFF3B82F6) : (isDark ? Colors.grey[500] : Colors.grey[400]),
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
