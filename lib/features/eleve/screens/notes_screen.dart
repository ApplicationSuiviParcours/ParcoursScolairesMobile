import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/eleve/providers/eleve_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class NotesScreen extends StatefulWidget {
  final int? childId;
  const NotesScreen({super.key, this.childId});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<EleveProvider>().loadNotes(childId: widget.childId);
    });
  }

  Color _getNoteColor(double note) {
    if (note < 8) return const Color(0xFFF97316);
    if (note < 10) return const Color(0xFFEF4444);
    if (note < 13) return const Color(0xFF10B981);
    return const Color(0xFF22C55E);
  }

  String _getAppreciation(double note) {
    if (note < 8) return 'À surveiller';
    if (note < 10) return 'Manque de travail';
    if (note < 14) return 'Travail sérieux';
    return 'Bon niveau';
  }

  Color _getAppreciationColor(double note) {
    if (note < 8) return const Color(0xFFF97316);
    if (note < 10) return const Color(0xFFEF4444);
    if (note < 14) return const Color(0xFF3B82F6);
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    final eleveProvider = context.watch<EleveProvider>();
    final notes = eleveProvider.notes;
    final theme = Theme.of(context);

    double totalNotes = 0;
    double maxNote = 0;
    double minNote = 20;
    int aSurveiller = 0;

    for (var n in notes) {
      if (n == null || n['note'] == null) continue;
      double val = (n['note'] is num) ? (n['note'] as num).toDouble() : double.tryParse(n['note'].toString()) ?? 0.0;
      totalNotes += val;
      if (val > maxNote) maxNote = val;
      if (val < minNote) minNote = val;
      if (val < 10) aSurveiller++;
    }

    double moyenne = notes.isEmpty ? 0 : totalNotes / notes.length;
    if (minNote == 20 && notes.isEmpty) minNote = 0;
    double percentage = notes.isEmpty ? 0 : (moyenne / 20) * 100;

    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : Colors.black87;

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
          'Mes Notes',
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
              : notes.isEmpty
                  ? _buildEmptyState(theme)
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOverviewCard(moyenne, percentage),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                _buildStatCard(notes.length.toString(), 'Évaluations', Icons.assignment, const Color(0xFF10B981), isDark),
                                _buildStatCard('${maxNote.toStringAsFixed(1)}', 'Meilleure note', Icons.trending_up, const Color(0xFF3B82F6), isDark, suffix: ' / 20'),
                                _buildStatCard('${minNote.toStringAsFixed(1)}', 'Plus basse note', Icons.bar_chart, const Color(0xFFF97316), isDark, suffix: ' / 20'),
                                _buildStatCard(aSurveiller.toString(), 'À surveiller', Icons.access_time_filled, const Color(0xFFA855F7), isDark),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Toutes mes notes',
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
                      padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final note = notes[index];
                            final val = (note['note'] as num).toDouble();
                            final noteColor = _getNoteColor(val);
                            final appText = note['appreciation'] ?? _getAppreciation(val);
                            final appColor = note['appreciation'] != null ? Colors.grey[600]! : _getAppreciationColor(val);
                            
                            return _buildNoteItem(note, val, noteColor, appText, appColor, isDark);
                          },
                          childCount: notes.length,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildOverviewCard(double moyenne, double percentage) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF818CF8), Color(0xFF93C5FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Moyenne générale', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(moyenne.toStringAsFixed(2), style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  Text(' / 20', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 14),
                    const SizedBox(width: 4),
                    Text('+1.25 par rapport au mois dernier', style: GoogleFonts.inter(color: const Color(0xFF6366F1), fontSize: 9, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${percentage.toInt()}%', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Réussite', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 9, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color, bool isDark, {String? suffix}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: GoogleFonts.poppins(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
                if (suffix != null)
                  Text(suffix, style: GoogleFonts.inter(color: color.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 9, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItem(Map<String, dynamic> note, double val, Color noteColor, String appText, Color appColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: noteColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                val.toString().replaceAll(RegExp(r'\.0$'), ''),
                style: GoogleFonts.poppins(color: noteColor, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.science, size: 16, color: Color(0xFF6366F1)), 
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        note['evaluation']?['matiere']?['nom'] ?? 'Matière',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.assignment_outlined, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        note['evaluation']?['titre'] ?? 'Évaluation',
                        style: GoogleFonts.inter(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('/20', style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: appColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: appColor, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(appText, style: GoogleFonts.inter(color: appColor, fontSize: 9, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Pas encore de notes',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos résultats s\'afficheront ici dès qu\'ils seront publiés.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
