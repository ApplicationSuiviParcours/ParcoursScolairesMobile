import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/features/enseignant/providers/enseignant_provider.dart';
import 'package:gestparc/shared/widgets/stat_card.dart';
import 'package:go_router/go_router.dart';
import 'package:gestparc/shared/widgets/app_drawer.dart';
import 'package:gestparc/core/utils/image_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class EnseignantDashboardScreen extends StatefulWidget {
  const EnseignantDashboardScreen({super.key});

  @override
  State<EnseignantDashboardScreen> createState() => _EnseignantDashboardScreenState();
}

class _EnseignantDashboardScreenState extends State<EnseignantDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<EnseignantProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final enseignantProvider = context.watch<EnseignantProvider>();
    final stats = enseignantProvider.stats;
    final photoUrl = ImageUtils.getAbsoluteUrl(user?['photo_url']);
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          _buildHeader(context, user, photoUrl),

          // Quick Stats Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(theme, 'Résumé d\'Activité', 'Statistiques clés'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard(theme, 'CLASSES', '${stats?['total_classes'] ?? 0}', Icons.school_rounded, const Color(0xFFEA580C)),
                      const SizedBox(width: 16),
                      _buildStatCard(theme, 'ÉLÈVES', '${stats?['total_eleves'] ?? 0}', Icons.people_rounded, Colors.indigo),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard(theme, 'ÉVALS', '${stats?['total_evaluations'] ?? 0}', Icons.assignment_rounded, Colors.deepOrange),
                      const SizedBox(width: 16),
                      _buildStatCard(theme, 'ABSENCES', '${stats?['total_absences'] ?? 0}', Icons.person_off_rounded, Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(theme, 'Mes Classes', 'Gestion des cours'),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Assignments List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: enseignantProvider.isLoading
              ? _buildSkeletonList()
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final assignment = enseignantProvider.assignments[index];
                      return _buildAssignmentCard(context, theme, assignment);
                    },
                    childCount: enseignantProvider.assignments.length,
                  ),
                ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/enseignant/evaluations/new'),
        backgroundColor: const Color(0xFFEA580C),
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('ÉVALUATION', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: Colors.white)),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.primary.withOpacity(0.7),
            letterSpacing: 1.2,
          ),
        ),
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, String photoUrl) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFEA580C),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.menu_rounded, color: Colors.white, size: 20),
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        _buildProfileAvatar(context, photoUrl),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                ),
              ),
            ),
            Positioned(
              top: -30,
              left: -30,
              child: Icon(Icons.history_edu_rounded, size: 150, color: Colors.white.withOpacity(0.05)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      'ESPACE ENSEIGNANT',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bonjour, ${user?['name']?.split(' ')[0] ?? 'Prof.'} 👨‍🏫',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1),
                  ),
                  Text(
                    'Gérez vos classes et évaluations.',
                    style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, String photoUrl) {
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 18) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, ThemeData theme, dynamic assignment) {
    final color = const Color(0xFFF97316);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: color.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.class_rounded, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(assignment['classe_nom'] ?? 'Classe', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      Text(assignment['matiere_nom'] ?? 'Matière', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${assignment['nb_eleves']}', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 18, color: color)),
                    Text('ÉLÈVES', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: Colors.indigo.withOpacity(0.2)),
                    ),
                    icon: const Icon(Icons.edit_note_rounded, size: 20, color: Colors.indigo),
                    label: const Text('NOTES', style: TextStyle(color: Colors.indigo, fontSize: 12, fontWeight: FontWeight.w800)),
                    onPressed: () => context.push('/enseignant/notes/${assignment['classe_id']}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: Colors.green.withOpacity(0.2)),
                    ),
                    icon: const Icon(Icons.how_to_reg_rounded, size: 20, color: Colors.green),
                    label: const Text('APPEL', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w800)),
                    onPressed: () => context.push('/enseignant/appel/${assignment['classe_id']}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 180,
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(28)),
        ),
        childCount: 2,
      ),
    );
  }
}
