import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/eleve/providers/eleve_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class BulletinDetailScreen extends StatefulWidget {
  final int bulletinId;
  final int? childId;

  const BulletinDetailScreen({super.key, required this.bulletinId, this.childId});

  @override
  State<BulletinDetailScreen> createState() => _BulletinDetailScreenState();
}

class _BulletinDetailScreenState extends State<BulletinDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _bulletin;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final provider = context.read<EleveProvider>();
      final data = await provider.getBulletinDetail(widget.bulletinId, childId: widget.childId);
      setState(() {
        _bulletin = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  IconData _getSubjectIcon(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('musique')) return Icons.music_note_rounded;
    if (s.contains('histoire') || s.contains('géo')) return Icons.menu_book_rounded;
    if (s.contains('math')) return Icons.calculate_rounded;
    if (s.contains('physique') || s.contains('chimie') || s.contains('science')) return Icons.science_rounded;
    if (s.contains('sport') || s.contains('eps')) return Icons.sports_basketball_rounded;
    if (s.contains('anglais') || s.contains('espagnol') || s.contains('langue')) return Icons.language_rounded;
    return Icons.library_books_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          _bulletin?['periode'] != null ? 'Détails - ${_bulletin!['periode']}' : 'Détails du Bulletin',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, color: textColor),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: textColor)))
              : _bulletin == null
                  ? Center(child: Text('Bulletin non trouvé.', style: TextStyle(color: textColor)))
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Column(
                              children: [
                                _buildSummaryCard(isDark),
                                const SizedBox(height: 20),
                                _buildStatsGrid(isDark),
                                const SizedBox(height: 20),
                                _buildAppreciationSection(isDark),
                                const SizedBox(height: 32),
                                _buildNotesHeader(isDark, (_bulletin!['notes'] as List?)?.length ?? 0),
                                const SizedBox(height: 12),
                                _buildTableLabels(isDark),
                              ],
                            ),
                          ),
                        ),
                        _buildNotesList(isDark),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                            child: _buildBottomInfo(isDark),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    double moyenne = double.tryParse(_bulletin!['moyenne_generale']?.toString() ?? '0') ?? 0;
    double percentage = (moyenne / 20) * 100;
    
    String mention = '';
    Color mentionColor = Colors.white;
    if (moyenne >= 16) { mention = 'Très Bien'; mentionColor = const Color(0xFF10B981); }
    else if (moyenne >= 14) { mention = 'Bien'; mentionColor = const Color(0xFF10B981); }
    else if (moyenne >= 12) { mention = 'Assez Bien'; mentionColor = const Color(0xFFF59E0B); }
    else if (moyenne >= 10) { mention = 'Passable'; mentionColor = const Color(0xFFF59E0B); }
    else { mention = 'Insuffisant'; mentionColor = const Color(0xFFEF4444); }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF5D5FEF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF5D5FEF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MOYENNE GÉNÉRALE', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(moyenne.toStringAsFixed(1), style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  Text(' /20', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: mentionColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(mention, style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70, height: 70,
                child: CircularProgressIndicator(value: percentage / 100, strokeWidth: 6, color: const Color(0xFF2DD4BF), backgroundColor: Colors.white.withOpacity(0.1)),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${percentage.toInt()}%', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('Niveau global', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 7, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.emoji_events, color: Colors.white, size: 20),
                const SizedBox(height: 8),
                Text('Continue comme ça ! Tu es sur la bonne voie.', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 9, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.1,
      children: [
        _buildStatTile('Rang', '${_bulletin!['rang'] ?? '-'}${_bulletin!['effectif_classe'] != null ? ' / ${_bulletin!['effectif_classe']}' : ''}', 'Parmi les meilleurs !', Icons.emoji_events_outlined, const Color(0xFFF59E0B), isDark),
        _buildStatTile('Classe', '${_bulletin!['moyenne_classe'] ?? '-'} / 20', 'Moyenne de la classe', Icons.groups_outlined, const Color(0xFF3B82F6), isDark),
        _buildStatTile('Période', _bulletin!['periode'] ?? '-', 'Sept. - Déc. 2024', Icons.calendar_today_outlined, const Color(0xFF10B981), isDark),
        _buildStatTile('Écart', '${_bulletin!['ecart_classe'] ?? '0.00'}', 'Au-dessus de la moyenne', Icons.show_chart_rounded, const Color(0xFF8B5CF6), isDark),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, String subtext, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtext, style: GoogleFonts.inter(fontSize: 8, color: isDark ? color.withOpacity(0.8) : color, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppreciationSection(bool isDark) {
    final appreciation = _bulletin!['appreciation'] ?? 'Bon travail global';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF451A03).withOpacity(0.3) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF97316).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFFF97316), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('APPRÉCIATION GÉNÉRALE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFFF97316), letterSpacing: 1)),
                const SizedBox(height: 8),
                Text('"$appreciation"', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 4),
                Text('Continue sur cette lancée, tes efforts paient !', style: GoogleFonts.inter(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600])),
              ],
            ),
          ),
          const Icon(Icons.workspace_premium, color: Color(0xFFF59E0B), size: 40),
        ],
      ),
    );
  }

  Widget _buildNotesHeader(bool isDark, int count) {
    return Row(
      children: [
        Text(
          'Détails des Notes',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18, color: isDark ? Colors.white : Colors.black87),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count Matières',
            style: GoogleFonts.inter(color: isDark ? Colors.grey[300] : Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildTableLabels(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(flex: 3, child: Text('Matière', style: GoogleFonts.inter(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[500]))),
          Expanded(flex: 2, child: Text('Notes obtenues', style: GoogleFonts.inter(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[500]))),
          SizedBox(width: 30, child: Text('/20', style: GoogleFonts.inter(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[500]))),
          Expanded(flex: 2, child: Text('Appréciation', style: GoogleFonts.inter(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[500]), textAlign: TextAlign.right)),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildNotesList(bool isDark) {
    final notes = _bulletin!['notes'] as List?;
    if (notes == null || notes.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('Aucune note détaillée disponible.', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        )),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final note = notes[index];
            return _buildNoteItem(note, index, isDark);
          },
          childCount: notes.length,
        ),
      ),
    );
  }

  Widget _buildNoteItem(dynamic note, int index, bool isDark) {
    final double? val = (note['note'] is num) ? (note['note'] as num).toDouble() : double.tryParse(note['note']?.toString() ?? '0');
    final String subjectName = note['matiere_nom'] ?? note['nom'] ?? 'Matière';
    
    String badgeText = 'Passable';
    Color badgeColor = const Color(0xFFF59E0B);
    Color progressColor = const Color(0xFF8B5CF6);

    if (val != null) {
      if (val >= 14) { badgeText = 'Très bien'; badgeColor = const Color(0xFF10B981); }
      else if (val >= 12) { badgeText = 'Bien'; badgeColor = const Color(0xFFF59E0B); }
      else if (val < 10) { badgeText = 'Insuffisant'; badgeColor = const Color(0xFFEF4444); }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), shape: BoxShape.circle),
            child: Center(child: Text('${index + 1}', style: GoogleFonts.inter(color: const Color(0xFF8B5CF6), fontSize: 11, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(_getSubjectIcon(subjectName), size: 16, color: const Color(0xFF8B5CF6)),
                const SizedBox(width: 8),
                Expanded(child: Text(subjectName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12, color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(val?.toStringAsFixed(1) ?? '-', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: val != null ? val / 20 : 0,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 22,
            child: Text('/20', style: GoogleFonts.inter(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 10)),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(badgeText, style: GoogleFonts.inter(color: badgeColor, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: isDark ? Colors.grey[500] : Colors.grey[400], size: 16),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(bool isDark) {
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2))),
            child: const Icon(Icons.info_outline_rounded, color: Color(0xFF3B82F6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ce bulletin reflète tes résultats pour le ${_bulletin!['periode'] ?? 'Trimestre 1'}.',
                  style: GoogleFonts.inter(color: const Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Reste motivé et continue à travailler régulièrement !',
                  style: GoogleFonts.inter(color: isDark ? Colors.blue[200] : const Color(0xFF3B82F6), fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.school_rounded, color: Color(0xFF6366F1), size: 40),
        ],
      ),
    );
  }
}
