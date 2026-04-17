import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Paramètres', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          _buildSection('Compte', [
            _buildSettingTile(Icons.security_rounded, 'Confidentialité', 'Sécurité et accès'),
            _buildSettingTile(Icons.notifications_active_outlined, 'Notifications', 'Alerte et sons'),
            _buildSettingTile(Icons.storage_rounded, 'Stockage et données', 'Utilisation réseau'),
          ]),
          const SizedBox(height: 12),
          _buildSection('Apparence', [
            _buildSettingTile(Icons.dark_mode_outlined, 'Mode sombre', 'Désactivé'),
            _buildSettingTile(Icons.translate_rounded, 'Langue', 'Français'),
          ]),
          const SizedBox(height: 12),
          _buildSection('Aide', [
            _buildSettingTile(Icons.help_outline_rounded, 'Centre d\'aide', 'FAQ, contactez-nous'),
            _buildSettingTile(Icons.description_outlined, 'Conditions et confidentialité', ''),
          ]),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              'GEST\'PARC Mobile v1.0.0',
              style: TextStyle(color: Colors.black26, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontSize: 13),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.black26),
      onTap: () {
        // TODO: Action
      },
    );
  }
}
