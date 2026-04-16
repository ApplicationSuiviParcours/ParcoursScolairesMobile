import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/features/parent/providers/parent_provider.dart';
import 'package:gestparc/shared/widgets/stat_card.dart';
import 'package:go_router/go_router.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ParentProvider>().loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final parentProvider = context.watch<ParentProvider>();
    final statsGlobal = parentProvider.statsGlobal;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Header Mirroring Web Gradient (Parent Theme: Deep Purple/Indigo)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF312E81), Color(0xFF4338CA), Color(0xFF6366F1)],
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
                            'Espace Parent',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bonjour, ${user?['name'] ?? 'Parent'} !',
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
                  // Global Stats Summary
                  Row(
                    children: [
                      _buildMiniStat(Icons.people_outline, '${statsGlobal?['total_enfants'] ?? 0} Enfants'),
                      const SizedBox(width: 12),
                      _buildMiniStat(Icons.assignment_outlined, '${statsGlobal?['total_notes'] ?? 0} Notes'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Children List Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text(
                'Mes Enfants',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Children Grid/List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: parentProvider.isLoading
              ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final enfant = parentProvider.enfants[index];
                      final stats = enfant['stats'];
                      
                      return GestureDetector(
                        onTap: () {
                          parentProvider.selectEnfant(enfant);
                          context.push('/parent/enfant/${enfant['id']}');
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4338CA).withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: const Color(0xFF4338CA).withValues(alpha: 0.1),
                                    child: Text(
                                      (enfant['prenom'] as String?)?[0] ?? 'E',
                                      style: const TextStyle(
                                        color: Color(0xFF4338CA),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${enfant['prenom']} ${enfant['nom']}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          enfant['inscription_active']?['classe']?['nom'] ?? 'Classe inconnue',
                                          style: const TextStyle(color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: Colors.black26),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Divider(height: 1),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildEnfantSummaryItem('Moyenne', '${stats?['moyenne_generale'] ?? '0.00'}', Colors.indigo),
                                  _buildEnfantSummaryItem('Absences', '${stats?['total_absences'] ?? 0}', Colors.orange),
                                  _buildEnfantSummaryItem('Evaluat.', '${stats?['total_notes'] ?? 0}', Colors.green),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: parentProvider.enfants.length,
                  ),
                ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEnfantSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black45),
        ),
      ],
    );
  }
}
