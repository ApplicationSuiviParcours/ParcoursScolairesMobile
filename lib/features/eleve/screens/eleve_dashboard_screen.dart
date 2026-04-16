import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/features/eleve/providers/eleve_provider.dart';
import 'package:gestparc/shared/widgets/stat_card.dart';
import 'package:go_router/go_router.dart';

class EleveDashboardScreen extends StatefulWidget {
  const EleveDashboardScreen({super.key});

  @override
  State<EleveDashboardScreen> createState() => _EleveDashboardScreenState();
}

class _EleveDashboardScreenState extends State<EleveDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<EleveProvider>().loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final eleveProvider = context.watch<EleveProvider>();
    final stats = eleveProvider.dashboardData?['stats'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Header Mirroring Web Gradient
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFDB2777)],
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tableau de bord',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bonjour, ${user?['name'] ?? 'Élève'} !',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Colors.white),
                          onPressed: () => context.read<AuthProvider>().logout(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Current Class Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.class_outlined, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          eleveProvider.dashboardData?['classe']?['nom'] ?? 'Chargement...',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats Grid
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: eleveProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/eleve/notes'),
                        child: StatCard(
                          title: 'Moyenne',
                          value: '${stats?['moyenne_generale'] ?? '0.00'}',
                          icon: Icons.auto_graph_rounded,
                          color: Colors.indigo,
                          subtitle: '/20',
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/eleve/absences'),
                        child: StatCard(
                          title: 'Absences',
                          value: '${stats?['total_absences'] ?? '0'}',
                          icon: Icons.warning_amber_rounded,
                          color: Colors.orange,
                          subtitle: (stats?['absences_non_justifiees'] ?? 0) > 0 ? '${stats?['absences_non_justifiees']} non justif.' : null,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/eleve/notes'),
                        child: StatCard(
                          title: 'Évaluations',
                          value: '${stats?['total_notes'] ?? '0'}',
                          icon: Icons.assignment_outlined,
                          color: Colors.green,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/eleve/bulletins'),
                        child: StatCard(
                          title: 'Bulletins',
                          value: '${stats?['nb_bulletins'] ?? '0'}',
                          icon: Icons.description_outlined,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
            ),
          ),

          // Recent Activity Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Activités Récentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/eleve/notes'),
                    child: const Text(
                      'Voir tout',
                      style: TextStyle(
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Recent Activities List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final recentNotes = eleveProvider.dashboardData?['recent']?['notes'] as List? ?? [];
                  if (recentNotes.isEmpty) {
                    return const Center(child: Text('Aucune activité récente'));
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
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.note_add_outlined, color: Color(0xFF4F46E5)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note['evaluation']?['matiere']?['nom'] ?? 'Évaluation',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                '${note['evaluation']?['nom'] ?? 'Contrôle'} - ${note['evaluation']?['date_evaluation'] ?? ''}',
                                style: const TextStyle(color: Colors.black54, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${note['note']}/20',
                            style: const TextStyle(
                              color: Color(0xFF059669),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: (eleveProvider.dashboardData?['recent']?['notes'] as List? ?? []).length.clamp(0, 5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
