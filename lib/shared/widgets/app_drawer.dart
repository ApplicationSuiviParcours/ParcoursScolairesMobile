import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final role = authProvider.role ?? 'Utilisateur';

    // Get photo URL from the nested profile or the main user object
    String? photoUrl;
    if (user != null) {
      photoUrl = user['photo_url'];
      if (photoUrl == null && user['profile'] != null) {
        photoUrl = user['profile']['photo']; // This should now be full URL from API
      }
    }

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header: WhatsApp-like clean profile view
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: photoUrl != null 
                        ? NetworkImage(photoUrl) 
                        : null,
                    child: photoUrl == null 
                        ? const Icon(Icons.person, size: 40, color: Colors.grey) 
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?['name'] ?? 'Utilisateur',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getRoleLabel(role),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.notifications_none_outlined,
                  label: 'Notifications',
                  onTap: () => context.push('/notifications'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline_rounded,
                  label: 'Mon Profil',
                  onTap: () => context.push('/profile'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  label: 'Paramètres',
                  onTap: () => context.push('/settings'),
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline_rounded,
                  label: 'Aide & Support',
                  onTap: () {
                    // TODO: Open help
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline_rounded,
                  label: 'À propos',
                  onTap: () {
                    // TODO: Open about
                  },
                ),
              ],
            ),
          ),
          
          // Footer
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.logout_rounded,
            label: 'Déconnexion',
            color: Colors.redAccent,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Déconnecter'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                authProvider.logout();
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
    );
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'eleve': return 'Élève';
      case 'enseignant': return 'Enseignant';
      case 'parent': return 'Parent';
      case 'administrateur': return 'Administrateur';
      default: return role;
    }
  }

  List<Color> _getRoleColors(String role) {
    switch (role.toLowerCase()) {
      case 'eleve': 
        return [const Color(0xFF4F46E5), const Color(0xFF7C3AED)];
      case 'enseignant': 
        return [const Color(0xFFEA580C), const Color(0xFFF97316)];
      case 'parent': 
        return [const Color(0xFF059669), const Color(0xFF10B981)];
      default: 
        return [const Color(0xFF4F46E5), const Color(0xFF6366F1)];
    }
  }
}
