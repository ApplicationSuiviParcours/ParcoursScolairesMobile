import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/enseignant/providers/enseignant_provider.dart';
import 'package:go_router/go_router.dart';

class ClasseDetailScreen extends StatefulWidget {
  const ClasseDetailScreen({super.key});

  @override
  State<ClasseDetailScreen> createState() => _ClasseDetailScreenState();
}

class _ClasseDetailScreenState extends State<ClasseDetailScreen> {
  Map<String, dynamic>? _classeData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final enseignantProvider = context.read<EnseignantProvider>();
    // Get class ID from router state (assuming path is /enseignant/classe/:id)
    final idStr = GoRouterState.of(context).pathParameters['id'];
    if (idStr != null) {
      try {
        final data = await enseignantProvider.loadClasseEleves(int.parse(idStr));
        if (mounted) {
          setState(() {
            _classeData = data;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_classeData == null) return const Scaffold(body: Center(child: Text('Erreur de chargement.')));

    final eleves = _classeData!['eleves'] as List? ?? [];
    final classe = _classeData!['classe'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(classe['nom'] ?? 'Classe', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Quick Action Banner
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    Icons.note_add_outlined,
                    'Saisie Notes',
                    const Color(0xFF4F46E5),
                    () => context.push('/enseignant/notes/${classe['id']}'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    Icons.how_to_reg_outlined,
                    'Lancer l\'Appel',
                    const Color(0xFF059669),
                    () => context.push('/enseignant/appel/${classe['id']}'),
                  ),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Liste des élèves',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              itemCount: eleves.length,
              itemBuilder: (context, index) {
                final eleve = eleves[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFF1F5F9),
                        child: Text(
                          (eleve['prenom'] as String?)?[0] ?? 'E',
                          style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${eleve['prenom']} ${eleve['nom']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              eleve['matricule'] ?? '',
                              style: const TextStyle(color: Colors.black45, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
