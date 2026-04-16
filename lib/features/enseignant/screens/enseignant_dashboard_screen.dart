import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/features/enseignant/providers/enseignant_provider.dart';
import 'package:gestparc/shared/widgets/stat_card.dart';
import 'package:go_router/go_router.dart';

class EnseignantDashboardScreen extends StatefulWidget {
  const EnseignantDashboardScreen({super.key});

  @override
  State<EnseignantDashboardScreen> createState() => _EnseignantDashboardScreenState();
}

class _EnseignantDashboardScreenState extends State<EnseignantDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<EnseignantProvider>().loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final enseignantProvider = context.watch<EnseignantProvider>();
    final stats = enseignantProvider.stats;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Header Mirroring Web Gradient (Teacher Theme: Amber/Orange/Red)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEA580C), Color(0xFFF97316), Color(0xFFFB923C)],
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
                            'Espace Enseignant',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bonjour, M/Mme ${user?['name'] ?? 'l\'Enseignant'} !',
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
                  // Dashboard Stats
                  Row(
                    children: [
                      _buildMiniStat(Icons.school_outlined, '${stats?['total_classes'] ?? 0} Classes'),
                      const SizedBox(width: 12),
                      _buildMiniStat(Icons.people_outline, '${stats?['total_eleves'] ?? 0} Élèves'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Stats Grid
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: enseignantProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      StatCard(
                        title: 'Évaluations',
                        value: '${stats?['total_evaluations'] ?? 0}',
                        icon: Icons.assignment_outlined,
                        color: Colors.deepOrange,
                      ),
                      StatCard(
                        title: 'Absences',
                        value: '${stats?['total_absences'] ?? 0}',
                        icon: Icons.person_off_outlined,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
            ),
          ),

          // Classes Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Mes Classes & Matières',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Classes List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final classe = enseignantProvider.classes[index];
                  return GestureDetector(
                    onTap: () => context.push('/enseignant/classe/${classe['id']}'),
                    child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF97316).withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF97316).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.class_outlined, color: Color(0xFFF97316)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    classe['nom'] ?? 'Classe',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  Text(
                                    classe['matiere'] ?? 'Matière',
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${classe['nb_eleves']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                                const Text('élèves', style: TextStyle(fontSize: 10, color: Colors.black45)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildActionButton(Icons.note_add_outlined, 'Saisir Notes', Colors.indigo),
                            _buildActionButton(Icons.how_to_reg_outlined, 'Faire l\'Appel', Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
                childCount: enseignantProvider.classes.length,
              ),
            ),
          ),
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

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        // TODO: Navigation to note/absence entry
      },
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
