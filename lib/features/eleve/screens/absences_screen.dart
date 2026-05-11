import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/eleve/providers/eleve_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AbsencesScreen extends StatefulWidget {
  final int? childId;
  final int? anneeScolaireId;
  const AbsencesScreen({super.key, this.childId, this.anneeScolaireId});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<EleveProvider>().loadAbsences(
        childId: widget.childId,
        anneeScolaireId: widget.anneeScolaireId
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final eleveProvider = context.watch<EleveProvider>();
    final absences = eleveProvider.absences;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : Colors.black87;

    int total = absences.length;
    int justifiees = absences.where((a) {
      if (a == null) return false;
      final j = a['justifiee'];
      return j == true || j == 1 || j == '1' || j == 'true';
    }).length;
    int enAttente = total - justifiees;
    double pctJustifiees = total == 0 ? 0 : (justifiees / total);
    double pctAttente = total == 0 ? 0 : (enAttente / total);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Mes Absences',
          style: GoogleFonts.inter(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_outlined, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: eleveProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : eleveProvider.error != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Erreur: ${eleveProvider.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                ))
              : absences.isEmpty
                  ? _buildEmptyState(theme)
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOverviewCard(total, justifiees, enAttente, pctJustifiees, pctAttente, isDark),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Liste des absences',
                                  style: GoogleFonts.inter(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Trier par ',
                                      style: GoogleFonts.inter(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Date',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF3B82F6),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF3B82F6), size: 16),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final absence = absences[index];
                            final isJustifiee = absence['justifiee'] == true || absence['justifiee'] == 1;
                            return _buildAbsenceItem(absence, isJustifiee, isDark);
                          },
                          childCount: absences.length,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 8),
                        child: _buildBottomReminder(isDark),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildOverviewCard(int total, int justifiees, int enAttente, double pctJustifiees, double pctAttente, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Icon + Text
          Expanded(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF8B5CF6), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Résumé des absences', style: GoogleFonts.inter(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('$total', style: GoogleFonts.poppins(color: const Color(0xFF6366F1), fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          Text('absence(s)', style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black87, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("Sur l'ensemble de ta scolarité", style: GoogleFonts.inter(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 9)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Middle: Circular Chart
          Expanded(
            flex: 3,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 75,
                    height: 75,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 6,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  SizedBox(
                    width: 75,
                    height: 75,
                    child: CircularProgressIndicator(
                      value: pctJustifiees,
                      strokeWidth: 6,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$justifiees', style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black87, fontSize: 14, fontWeight: FontWeight.bold, height: 1)),
                      Text('Justifiées', style: GoogleFonts.inter(color: const Color(0xFF10B981), fontSize: 8, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('$enAttente', style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold, height: 1)),
                      Text('En attente', style: GoogleFonts.inter(color: const Color(0xFFF59E0B), fontSize: 8, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Right: Legend
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFF10B981), 'Justifiées', '$justifiees (${(pctJustifiees*100).toStringAsFixed(1)}%)', isDark),
                const SizedBox(height: 8),
                _buildLegendItem(const Color(0xFFF59E0B), 'En attente', '$enAttente (${(pctAttente*100).toStringAsFixed(1)}%)', isDark),
                const SizedBox(height: 8),
                _buildLegendItem(Colors.grey[400]!, 'Total', '$total', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(margin: const EdgeInsets.only(top: 4), width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black87, fontSize: 9, fontWeight: FontWeight.w600)),
            Text(value, style: GoogleFonts.inter(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 9)),
          ],
        ),
      ],
    );
  }

  Widget _buildAbsenceItem(Map<String, dynamic> absence, bool isJustifiee, bool isDark) {
    final color = isJustifiee ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final icon = isJustifiee ? Icons.verified_rounded : Icons.warning_rounded;
    final badgeText = isJustifiee ? 'Justifiée' : 'En attente';
    String dateStr = absence['date_absence'] ?? 'Date inconnue';
    if (dateStr.contains('T')) {
      dateStr = dateStr.split('T')[0];
    }
    
    String timeStr = 'Non spécifié';
    if (absence['heure_debut'] != null && absence['heure_fin'] != null) {
      timeStr = '${absence['heure_debut']} - ${absence['heure_fin']}';
    } else if (absence['heure_debut'] != null) {
      timeStr = 'À partir de ${absence['heure_debut']}';
    } else if (absence['date_absence'] != null && absence['date_absence'].toString().contains('T')) {
      final parts = absence['date_absence'].toString().split('T');
      if (parts.length > 1 && parts[1].length >= 5) {
        timeStr = parts[1].substring(0, 5);
      }
    }
    
    final statusText = isJustifiee 
      ? 'Absence justifiée le $dateStr.' 
      : 'En attente de justification par un responsable.';
    final statusIcon = isJustifiee ? Icons.check_circle_outline : Icons.info_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            absence['matiere']?['nom'] ?? 'Matière',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(dateStr, style: GoogleFonts.inter(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time_outlined, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(timeStr, style: GoogleFonts.inter(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Icon(Icons.chevron_right, color: isDark ? Colors.grey[500] : Colors.grey[400], size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: color, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText,
                    style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
                if (!isJustifiee && widget.childId != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _showJustifyDialog(context, absence['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Justifier', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomReminder(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.3) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: const Icon(Icons.edit_calendar_rounded, color: Color(0xFF3B82F6), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pense à justifier tes absences',
                  style: GoogleFonts.inter(color: const Color(0xFF2563EB), fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toute absence doit être justifiée dans un délai de 48h pour être prise en compte.',
                  style: GoogleFonts.inter(color: isDark ? Colors.blue[200] : const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFF3B82F6), size: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.green.withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          Text(
            'Zéro Absences !',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            'Félicitations, vous avez été présent à tous vos cours.',
            style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.grey[500] : Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showJustifyDialog(BuildContext context, int absenceId) {
    final motifController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Justifier l\'absence', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          content: TextField(
            controller: motifController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Saisissez le motif...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler', style: GoogleFonts.inter(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                if (motifController.text.trim().isEmpty) return;
                Navigator.pop(context);
                try {
                  await context.read<EleveProvider>().justifyAbsence(
                    absenceId, 
                    motifController.text.trim(), 
                    childId: widget.childId
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Absence justifiée avec succès !'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erreur lors de la justification'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }
}
