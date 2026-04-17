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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                    subtitle: (stats?['absences_non_justifiees'] ?? 0) > 0 ? '${stats?['absences_non_justifiees']} non justif.' : null,
                  ),
                  StatCard(
                    title: 'Évaluations',
                    value: '${stats?['total_notes'] ?? '0'}',
                    icon: Icons.assignment_outlined,
                    color: Colors.green,
                  ),
                  StatCard(
                    title: 'Bulletins',
                    value: stats?['dernier_bulletin'] != null ? 'Disponible' : 'Aucun',
                    icon: Icons.description_outlined,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),

          // Performance par Matière (New)
          if (stats?['moyennes_par_matiere'] != null && (stats['moyennes_par_matiere'] as List).isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance par Matière',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: (stats?['moyennes_par_matiere'] as List).take(5).map<Widget>((m) {
                          final double moyenne = (m['moyenne'] as num).toDouble();
                          final color = moyenne >= 14 ? Colors.green : (moyenne >= 10 ? Colors.orange : Colors.red);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(m['nom'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                    Text('$moyenne/20', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: moyenne / 20,
                                    backgroundColor: color.withValues(alpha: 0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(color),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Dernier Bulletin (New)
          if (stats?['dernier_bulletin'] != null)
             SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dernier Bulletin',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF334155)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stats?['dernier_bulletin']?['periode']?.toUpperCase() ?? '',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Moyenne: ${stats?['dernier_bulletin']?['moyenne']}/20',
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rang: ${stats?['dernier_bulletin']?['rang'] ?? '-'}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 32),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Recent Activity Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
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
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
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
                                '${note['evaluation']?['nom'] ?? 'Contrôle'} - ${note['evaluation']?['date_evaluation'] ?? ''}',
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
