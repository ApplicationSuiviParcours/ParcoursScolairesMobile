import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/parent/providers/parent_provider.dart';
import 'package:gestparc/shared/widgets/stat_card.dart';
import 'package:go_router/go_router.dart';

class EnfantDetailScreen extends StatelessWidget {
  const EnfantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final parentProvider = context.watch<ParentProvider>();
    final enfant = parentProvider.selectedEnfant;

    if (enfant == null) {
      return const Scaffold(body: Center(child: Text('Aucun enfant sélectionné.')));
    }

    final stats = enfant['stats'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Header Mirroring Web Gradient (Special theme for specific child detail)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4338CA), Color(0xFF6366F1), Color(0xFF818CF8)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Suivi Individuel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          (enfant['prenom'] as String?)?[0] ?? 'E',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${enfant['prenom']} ${enfant['nom']}',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            enfant['inscription_active']?['classe']?['nom'] ?? 'Classe inconnue',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Stats Grid (Mirroring Eleve Dashboard)
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  StatCard(
                    title: 'Moyenne',
                    value: '${stats?['moyenne_generale'] ?? '0.00'}',
                    icon: Icons.auto_graph_rounded,
                    color: Colors.indigo,
                    subtitle: '/20',
                  ),
                  StatCard(
                    title: 'Absences',
                    value: '${stats?['total_absences'] ?? '0'}',
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange,
                    subtitle: stats?['absences_non_justifiees'] > 0 ? '${stats?['absences_non_justifiees']} non justif.' : null,
                  ),
                  StatCard(
                    title: 'Évaluations',
                    value: '${stats?['total_notes'] ?? '0'}',
                    icon: Icons.assignment_outlined,
                    color: Colors.green,
                  ),
                  StatCard(
                    title: 'Bulletins',
                    value: enfant['dernier_bulletin'] != null ? 'Disponible' : 'N/A',
                    icon: Icons.description_outlined,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),

          // Recent Activity Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Dernières Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Recent Activities List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final recentNotes = stats?['dernieres_notes'] as List? ?? [];
                  if (recentNotes.isEmpty) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Aucune note récente'),
                    ));
                  }
                  final note = recentNotes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4338CA).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.note_add_outlined, color: Color(0xFF4338CA), size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note['evaluation']?['matiere']?['nom'] ?? 'Évaluation',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                note['evaluation']?['nom'] ?? 'Contrôle',
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${note['note']}/20',
                          style: const TextStyle(
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: (stats?['dernieres_notes'] as List? ?? []).length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
