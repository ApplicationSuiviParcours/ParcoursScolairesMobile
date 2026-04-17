import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final role = authProvider.role ?? 'Utilisateur';
    final photoUrl = user?['photo_url'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Photo
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _getRoleColor(role).withValues(alpha: 0.2), width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                          child: photoUrl == null 
                              ? const Icon(Icons.person, size: 60, color: Colors.grey) 
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getRoleColor(role),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?['name'] ?? 'Nom Inconnu',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRoleLabel(role),
                    style: TextStyle(color: _getRoleColor(role), fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Info Sections
            _buildSection(
              'Informations Personnelles',
              [
                _buildInfoTile(Icons.email_outlined, 'Email', user?['email'] ?? 'Non renseigné'),
                _buildInfoTile(Icons.phone_android_rounded, 'Téléphone', user?['profile']?['telephone'] ?? 'Non renseigné'),
                _buildInfoTile(Icons.location_on_outlined, 'Adresse', user?['profile']?['adresse'] ?? 'Non renseignée'),
              ],
            ),
            
            const SizedBox(height: 12),
            
            _buildSection(
              'Informations Académiques',
              [
                _buildInfoTile(Icons.badge_outlined, 'Matricule', user?['profile']?['matricule'] ?? 'N/A'),
                if (role == 'eleve')
                  _buildInfoTile(Icons.school_outlined, 'Classe actuelle', user?['profile']?['classe_actuelle']?['nom_complet'] ?? 'N/A'),
                if (role == 'enseignant')
                  _buildInfoTile(Icons.workspace_premium_outlined, 'Spécialité', user?['profile']?['specialite'] ?? 'N/A'),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Edit profile
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getRoleColor(role),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Modifier le profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black54, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.black38, fontSize: 13)),
                Text(value, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
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
      case 'administrateur': return 'Administrateur';
      default: return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'eleve': return const Color(0xFF4F46E5);
      case 'enseignant': return const Color(0xFFEA580C);
      case 'parent': return const Color(0xFF059669);
      default: return const Color(0xFF4F46E5);
    }
  }
}
