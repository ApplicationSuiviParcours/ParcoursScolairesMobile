import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/core/theme/theme_provider.dart';
import 'package:gestparc/core/utils/image_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final user = authProvider.user;
    final role = authProvider.role ?? 'Utilisateur';

    String photoUrl = '';
    if (user != null) {
      photoUrl = ImageUtils.getAbsoluteUrl(user['photo_url'] ?? (user['profile']?['photo']));
    }

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          _buildHeader(context, user, role, photoUrl),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text('MA SCOLARITÉ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
                ),

                if (role == 'eleve') ..._buildEleveItems(context),
                if (role == 'enseignant') ..._buildEnseignantItems(context),
                if (role == 'parent') ..._buildParentItems(context),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Divider(height: 1),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text('PARAMÈTRES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
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
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Mode Sombre',
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    trailing: Switch.adaptive(
                      value: themeProvider.isDarkMode,
                      onChanged: (val) => themeProvider.toggleTheme(),
                      activeColor: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          _buildLogoutBtn(context, authProvider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, String role, String photoUrl) {
    final theme = Theme.of(context);
    final roleColors = _getRoleColors(role);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: roleColors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: ClipOval(
                    child: photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.person_rounded, size: 40, color: Colors.white),
                          )
                        : const Icon(Icons.person_rounded, size: 40, color: Colors.white),
                  ),
                ),
              ),
              const Spacer(),
              Image.asset('assets/images/logo.png', height: 40, color: Colors.white.withOpacity(0.8)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            user?['name'] ?? 'Utilisateur',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getRoleLabel(role).toUpperCase(),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEleveItems(BuildContext context) => [
    _buildDrawerItem(context, icon: Icons.assignment_rounded, label: 'Mes Notes', onTap: () => context.push('/eleve/notes')),
    _buildDrawerItem(context, icon: Icons.event_busy_rounded, label: 'Mes Absences', onTap: () => context.push('/eleve/absences')),
    _buildDrawerItem(context, icon: Icons.folder_shared_rounded, label: 'Mes Bulletins', onTap: () => context.push('/eleve/bulletins')),
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
    final primaryColor = theme.colorScheme.primary;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color ?? primaryColor, size: 20),
        ),
        title: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  Widget _buildLogoutBtn(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.1),
          foregroundColor: Colors.redAccent,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () => _showLogoutDialog(context, auth),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text('DÉCONNEXION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment quitter l\'application ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); auth.logout(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Oui, Quitter'),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'eleve': return 'Portail Élève';
      case 'enseignant': return 'Portail Enseignant';
      case 'parent': return 'Portail Parent';
      case 'administrateur': return 'Administration';
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

