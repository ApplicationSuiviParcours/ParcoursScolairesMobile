import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/core/utils/image_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final role = authProvider.role ?? 'Utilisateur';
    final photoUrl = ImageUtils.getAbsoluteUrl(user?['photo_url'] ?? user?['profile']?['photo']);
    final theme = Theme.of(context);
    final color = _getRoleColor(role);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Background and Photo
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withOpacity(0.8)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                        child: photoUrl.isEmpty 
                            ? Icon(Icons.person_rounded, size: 65, color: color.withOpacity(0.5)) 
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 70),
            
            // Name and Role
            Column(
              children: [
                Text(
                  user?['name'] ?? 'Nom Inconnu',
                  style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getRoleLabel(role).toUpperCase(),
                    style: GoogleFonts.inter(
                      color: color, 
                      fontWeight: FontWeight.w900, 
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Info Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileCard(
                    theme,
                    'Informations Personnelles',
                    [
                      _buildInfoRow(theme, Icons.email_outlined, 'Email', user?['email'] ?? 'Non renseigné'),
                      _buildInfoRow(theme, Icons.phone_iphone_rounded, 'Téléphone', user?['profile']?['telephone'] ?? 'Non renseigné'),
                      _buildInfoRow(theme, Icons.location_on_outlined, 'Adresse', user?['profile']?['adresse'] ?? 'Non renseignée'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildProfileCard(
                    theme,
                    'Statut Académique',
                    [
                      _buildInfoRow(theme, Icons.badge_outlined, 'Matricule', user?['profile']?['matricule'] ?? 'N/A'),
                      if (role == 'eleve')
                        _buildInfoRow(theme, Icons.school_outlined, 'Classe', user?['profile']?['classe_actuelle']?['nom_complet'] ?? 'N/A'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12, 
              fontWeight: FontWeight.w900, 
              color: theme.colorScheme.primary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'eleve': return 'Compte Élève';
      case 'parent': return 'Compte Parent';
      case 'administrateur': return 'Compte Admin';
      default: return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'eleve': return const Color(0xFF6366F1);
      case 'parent': return const Color(0xFF10B981);
      default: return const Color(0xFF6366F1);
    }
  }
}

