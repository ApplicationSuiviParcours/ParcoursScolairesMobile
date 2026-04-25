import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/core/theme/theme_provider.dart';
import 'package:gestparc/core/utils/image_utils.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final user = authProvider.user;
    final role = authProvider.role ?? 'Utilisateur';

    // Get photo URL
    String photoUrl = '';
    if (user != null) {
      photoUrl = ImageUtils.getAbsoluteUrl(user['photo_url'] ?? (user['profile']?['photo']));
    }

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header: Premium Profile View
          _buildHeader(context, user, role, photoUrl),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  label: 'Tableau de bord',
                  onTap: () {
                    if (role == 'eleve') context.go('/eleve');
                    else if (role == 'parent') context.go('/parent');
                    else if (role == 'enseignant') context.go('/enseignant');
                  },
                ),

                if (role == 'eleve') ..._buildEleveItems(context),
                if (role == 'enseignant') ..._buildEnseignantItems(context),
                if (role == 'parent') ..._buildParentItems(context),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(thickness: 0.5),
                ),
                
                _buildDrawerItem(
                  context,
                  icon: Icons.notifications_rounded,
                  label: 'Notifications',
                  onTap: () => context.push('/notifications'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_rounded,
                  label: 'Mon Profil',
                  onTap: () => context.push('/profile'),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(thickness: 0.5),
                ),

                // Theme Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SwitchListTile(
                    secondary: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: theme.iconTheme.color,
                    ),
                    title: Text(
                      themeProvider.isDarkMode ? 'Mode Sombre' : 'Mode Claire',
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    value: themeProvider.isDarkMode,
                    onChanged: (val) => themeProvider.toggleTheme(),
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Logout Footer
          _buildLogoutBtn(context, authProvider),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, String role, String photoUrl) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 30),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getRoleColors(role),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white24,
              backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty ? const Icon(Icons.person, size: 38, color: Colors.white) : null,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user?['name'] ?? 'Utilisateur',
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
            child: Text(
              _getRoleLabel(role).toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEleveItems(BuildContext context) => [
    _buildDrawerItem(context, icon: Icons.assignment_rounded, label: 'Mes Notes', onTap: () => context.push('/eleve/notes')),
    _buildDrawerItem(context, icon: Icons.person_off_rounded, label: 'Mes Absences', onTap: () => context.push('/eleve/absences')),
    _buildDrawerItem(context, icon: Icons.description_rounded, label: 'Mes Bulletins', onTap: () => context.push('/eleve/bulletins')),
    _buildDrawerItem(context, icon: Icons.calendar_month_rounded, label: 'Emploi du temps', onTap: () => context.push('/eleve/emploi')),
  ];

  List<Widget> _buildEnseignantItems(BuildContext context) => [
    _buildDrawerItem(context, icon: Icons.class_rounded, label: 'Mes Classes', onTap: () => context.go('/enseignant')),
    _buildDrawerItem(context, icon: Icons.assignment_rounded, label: 'Évaluations', onTap: () => context.push('/enseignant/evaluations')),
  ];

  List<Widget> _buildParentItems(BuildContext context) => [
    _buildDrawerItem(context, icon: Icons.family_restroom_rounded, label: 'Mes Enfants', onTap: () => context.go('/parent')),
  ];

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: color ?? theme.colorScheme.onSurface.withOpacity(0.7)),
        title: Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: color)),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  Widget _buildLogoutBtn(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Colors.redAccent,
          minimumSize: const Size(double.infinity, 50),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: () => _showLogoutDialog(context, auth),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Déconnexion', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment quitter l\'application ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); auth.logout(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'eleve': return 'Élève';
      case 'enseignant': return 'Enseignant';
      case 'parent': return 'Parent';
      case 'administrateur': return 'Admin';
      default: return role;
    }
  }

  List<Color> _getRoleColors(String role) {
    switch (role.toLowerCase()) {
      case 'eleve': return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
      case 'enseignant': return [const Color(0xFFF59E0B), const Color(0xFFEF4444)];
      case 'parent': return [const Color(0xFF10B981), const Color(0xFF059669)];
      default: return [const Color(0xFF6366F1), const Color(0xFF6366F1)];
    }
  }
}
