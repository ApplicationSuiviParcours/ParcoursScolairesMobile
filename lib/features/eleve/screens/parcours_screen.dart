import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/eleve/providers/eleve_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ParcoursScreen extends StatefulWidget {
  final int? childId;
  const ParcoursScreen({super.key, this.childId});

  @override
  State<ParcoursScreen> createState() => _ParcoursScreenState();
}

class _ParcoursScreenState extends State<ParcoursScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<EleveProvider>().loadParcours(childId: widget.childId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final eleveProvider = context.watch<EleveProvider>();
    final parcours = eleveProvider.parcours;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : Colors.black87;
    final dashboardData = eleveProvider.dashboardData;
    final stats = dashboardData?['statsParcours'];
    final eleve = dashboardData?['eleveParcours'];

    return Scaffold(
      backgroundColor: bgColor,
      body: eleveProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildAppBar(context, eleve, textColor, bgColor),
                if (stats != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildStatsGrid(stats, isDark),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Mon Historique',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                if (parcours.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(isDark),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = parcours[index];
                          return _buildParcoursCard(context, item, isDark);
                        },
                        childCount: parcours.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
    );
  }

  Widget _buildAppBar(BuildContext context, dynamic eleve, Color textColor, Color bgColor) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: bgColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B5CF6),
                const Color(0xFF8B5CF6).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(Icons.history_edu_rounded, size: 150, color: Colors.white.withOpacity(0.1)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parcours Académique',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (eleve != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${eleve['prenom']} ${eleve['nom']}',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(dynamic stats, bool isDark) {
    return Row(
      children: [
        _buildStatItem('Années', stats['total_annees']?.toString() ?? '0', Icons.calendar_today_rounded, const Color(0xFF6366F1), isDark),
        const SizedBox(width: 12),
        _buildStatItem('Moyenne', stats['moyenne_globale']?.toString() ?? '0.00', Icons.auto_graph_rounded, const Color(0xFF10B981), isDark),
        const SizedBox(width: 12),
        _buildStatItem('Bulletins', stats['total_bulletins']?.toString() ?? '0', Icons.grading_rounded, const Color(0xFFF59E0B), isDark),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildParcoursCard(BuildContext context, dynamic item, bool isDark) {
    final annee = item['annee_scolaire'];
    final classe = item['classe'];
    final anneeId = annee?['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.history_rounded, color: Color(0xFF8B5CF6), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        annee?['nom'] ?? 'Année Inconnue',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                      ),
                      Text(
                        classe?['nom'] ?? 'Classe Inconnue',
                        style: GoogleFonts.inter(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context, 
                  'Notes', 
                  Icons.assignment_rounded, 
                  const Color(0xFF6366F1), 
                  () => _navigateToNotes(context, anneeId),
                  isDark
                ),
                _buildActionButton(
                  context, 
                  'Absences', 
                  Icons.event_busy_rounded, 
                  const Color(0xFFF43F5E), 
                  () => _navigateToAbsences(context, anneeId),
                  isDark
                ),
                _buildActionButton(
                  context, 
                  'Bulletins', 
                  Icons.folder_shared_rounded, 
                  const Color(0xFFF59E0B), 
                  () => _navigateToBulletins(context, anneeId),
                  isDark
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  void _navigateToNotes(BuildContext context, int? anneeId) {
    if (widget.childId != null) {
      context.push('/parent/enfant/${widget.childId}/notes?annee_scolaire_id=$anneeId');
    } else {
      context.push('/eleve/notes?annee_scolaire_id=$anneeId');
    }
  }

  void _navigateToAbsences(BuildContext context, int? anneeId) {
    if (widget.childId != null) {
      context.push('/parent/enfant/${widget.childId}/absences?annee_scolaire_id=$anneeId');
    } else {
      context.push('/eleve/absences?annee_scolaire_id=$anneeId');
    }
  }

  void _navigateToBulletins(BuildContext context, int? anneeId) {
    if (widget.childId != null) {
      context.push('/parent/enfant/${widget.childId}/bulletins?annee_scolaire_id=$anneeId');
    } else {
      context.push('/eleve/bulletins?annee_scolaire_id=$anneeId');
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text(
            'Aucun historique',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[500]),
          ),
          Text(
            'Votre parcours commencera dès la fin de l\'année.',
            style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.grey[500] : Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
