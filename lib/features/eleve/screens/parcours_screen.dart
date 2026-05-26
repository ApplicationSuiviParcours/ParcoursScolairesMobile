import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/eleve/providers/eleve_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

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
                // Stats globales
                if (stats != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildStatsGrid(stats, isDark),
                    ),
                  ),
                // Graphique d'évolution trimestrielle
                if (parcours.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: _buildEvolutionSection(parcours, isDark),
                    ),
                  ),
                // Titre de section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Text(
                      'Mon Historique — année par année',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                // Liste ou état vide
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

  // ── AppBar ──────────────────────────────────────────────────────────────────
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(Icons.history_edu_rounded, size: 150, color: Colors.white.withValues(alpha: 0.1)),
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
                        eleve['nom_complet'] ?? '${eleve['prenom'] ?? ''} ${eleve['nom'] ?? ''}'.trim(),
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.9),
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

  // ── Stats globales ──────────────────────────────────────────────────────────
  Widget _buildStatsGrid(dynamic stats, bool isDark) {
    return Row(
      children: [
        _buildStatItem('Années', stats['nombre_annees']?.toString() ?? '0', Icons.calendar_today_rounded, const Color(0xFF6366F1), isDark),
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
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  // ── Graphique d'évolution trimestrielle ────────────────────────────────────
  Widget _buildEvolutionSection(List<dynamic> parcours, bool isDark) {
    final reversed = parcours.reversed.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Évolution de mes moyennes',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87),
          ),
          Text(
            'Progression par trimestre sur toutes les années',
            style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          // Légende
          Row(
            children: [
              _legendDot('Trimestre 1', const Color(0xFF6366F1), isDark),
              const SizedBox(width: 12),
              _legendDot('Trimestre 2', const Color(0xFF10B981), isDark),
              const SizedBox(width: 12),
              _legendDot('Trimestre 3', const Color(0xFFA855F7), isDark),
            ],
          ),
          const SizedBox(height: 12),
          // Graphique en barres groupées
          SizedBox(
            height: 150,
            child: reversed.isEmpty
                ? Center(child: Text('Aucune donnée', style: GoogleFonts.inter(color: Colors.grey.shade400)))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: reversed.map<Widget>((item) {
                      final trimestres = (item['trimestres'] as Map?)?.cast<String, dynamic>() ?? {};
                      final t1 = (trimestres['Trimestre 1']?['moyenne'] as num?)?.toDouble();
                      final t2 = (trimestres['Trimestre 2']?['moyenne'] as num?)?.toDouble();
                      final t3 = (trimestres['Trimestre 3']?['moyenne'] as num?)?.toDouble();
                      final nomAnnee = (item['annee_scolaire']?['nom'] as String? ?? '').split('-').last.trim();
                      return Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildBar(t1, const Color(0xFF6366F1)),
                                  const SizedBox(width: 2),
                                  _buildBar(t2, const Color(0xFF10B981)),
                                  const SizedBox(width: 2),
                                  _buildBar(t3, const Color(0xFFA855F7)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nomAnnee,
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Container(width: 20, height: 1.5, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text("Seuil d'admission : 10/20", style: GoogleFonts.inter(fontSize: 9, color: Colors.grey.shade400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildBar(double? value, Color color) {
    final pct = (value != null && value > 0) ? (value / 20.0).clamp(0.0, 1.0) : 0.0;
    return Expanded(
      child: Container(
        height: pct > 0 ? (pct * 110).clamp(4.0, 110.0) : 4,
        decoration: BoxDecoration(
          color: pct > 0 ? color : Colors.grey.shade200,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
    );
  }

  // ── Carte d'une année du parcours ──────────────────────────────────────────
  Widget _buildParcoursCard(BuildContext context, dynamic item, bool isDark) {
    final annee = item['annee_scolaire'];
    final classe = item['classe'];
    final anneeId = annee?['id'];
    final trimestres = (item['trimestres'] as Map?)?.cast<String, dynamic>() ?? {};
    final moyenneAnnuelle = (item['moyenne_annuelle'] as num?)?.toDouble();
    final estRedoublant = item['est_redoublant'] == true;

    // Décision
    String? decisionLabel;
    Color decisionColor = Colors.green;
    IconData decisionIcon = Icons.check_circle_outline;
    if (estRedoublant) {
      decisionLabel = 'Redoublant(e)';
      decisionColor = Colors.red;
      decisionIcon = Icons.replay_rounded;
    } else if (moyenneAnnuelle != null && moyenneAnnuelle >= 10) {
      decisionLabel = 'Admis(e)';
      decisionColor = Colors.green;
      decisionIcon = Icons.check_circle_outline;
    } else if (moyenneAnnuelle != null) {
      decisionLabel = 'En attente';
      decisionColor = Colors.orange;
      decisionIcon = Icons.hourglass_empty_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la carte
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
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
                        style: GoogleFonts.inter(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                // Badge décision
                if (decisionLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: decisionColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: decisionColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(decisionIcon, color: decisionColor, size: 12),
                        const SizedBox(width: 4),
                        Text(decisionLabel, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: decisionColor)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Grille Trimestre 1 / Trimestre 2 / Trimestre 3
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                _buildTrimCard('Trimestre 1', trimestres['Trimestre 1'], const Color(0xFF6366F1), isDark),
                const SizedBox(width: 8),
                _buildTrimCard('Trimestre 2', trimestres['Trimestre 2'], const Color(0xFF10B981), isDark),
                const SizedBox(width: 8),
                _buildTrimCard('Trimestre 3', trimestres['Trimestre 3'], const Color(0xFFA855F7), isDark),
              ],
            ),
          ),
          // Moyenne annuelle
          if (moyenneAnnuelle != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Text('Moyenne annuelle : ', style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  Text(
                    '${moyenneAnnuelle.toStringAsFixed(2)}/20',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: moyenneAnnuelle >= 10 ? Colors.green[600] : Colors.red[400],
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          // Boutons d'action
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(context, 'Notes', Icons.assignment_rounded, const Color(0xFF6366F1), () => _navigateToNotes(context, anneeId), isDark),
                _buildActionButton(context, 'Absences', Icons.event_busy_rounded, const Color(0xFFF43F5E), () => _navigateToAbsences(context, anneeId), isDark),
                _buildActionButton(context, 'Bulletins', Icons.folder_shared_rounded, const Color(0xFFF59E0B), () => _navigateToBulletins(context, anneeId), isDark),
              ],
            ),
          ),
          if (moyenneAnnuelle != null && moyenneAnnuelle >= 10)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _downloadCertificate(context, anneeId),
                    icon: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                    label: Text(
                      'CERTIFICAT DE RÉUSSITE',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Carte individuelle d'un trimestre
  Widget _buildTrimCard(String label, dynamic data, Color color, bool isDark) {
    final moyenne = (data?['moyenne'] as num?)?.toDouble();
    final rang = data?['rang'];
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: color), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              moyenne != null ? moyenne.toStringAsFixed(2) : '—',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w900, color: moyenne != null ? color : Colors.grey.shade300),
            ),
            if (rang != null)
              Text('Rang $rang', style: GoogleFonts.inter(fontSize: 8, color: color.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
          ],
        ),
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
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
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

  Future<void> _downloadCertificate(BuildContext context, int? anneeId) async {
    if (anneeId == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Génération du Certificat de Réussite en cours...'),
        backgroundColor: Color(0xFFF59E0B),
      ),
    );

    try {
      final provider = context.read<EleveProvider>();
      final bytes = await provider.downloadCertificate(anneeId, childId: widget.childId);

      if (bytes == null || bytes.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Échec du téléchargement du certificat.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Save file locally
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/certificat_reussite_$anneeId.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎓 Certificat généré ! Clique pour l\'ouvrir.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OUVRIR',
            textColor: Colors.white,
            onPressed: () {
              OpenFilex.open(filePath);
            },
          ),
        ),
      );

      // Automatically try to open the file
      await OpenFilex.open(filePath);

    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Une erreur est survenue: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          Text(
            'Aucun historique',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
          ),
          Text(
            "Votre parcours commencera dès la fin de l'année.",
            style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
