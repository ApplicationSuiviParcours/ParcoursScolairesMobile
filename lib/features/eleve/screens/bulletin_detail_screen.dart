import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/eleve/providers/eleve_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class BulletinDetailScreen extends StatefulWidget {
  final int bulletinId;

  const BulletinDetailScreen({super.key, required this.bulletinId});

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
      final data = await provider.getBulletinDetail(widget.bulletinId);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _bulletin?['periode'] != null ? 'Détails - ${_bulletin!['periode']}' : 'Détails du Bulletin',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _bulletin == null
                  ? const Center(child: Text('Bulletin non trouvé.'))
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildSummaryCard(theme),
                                const SizedBox(height: 24),
                                _buildStatsGrid(theme),
                                const SizedBox(height: 32),
                                _buildAppreciationSection(theme),
                                const SizedBox(height: 32),
                                _buildNotesHeader(theme),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                        _buildNotesList(theme),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'MOYENNE GÉNÉRALE',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${_bulletin!['moyenne_generale'] ?? 'N/A'}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                ' /20',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMentionBadge(_bulletin!['moyenne_generale']),
        ],
      ),
    );
  }

  Widget _buildMentionBadge(dynamic moyenne) {
    if (moyenne == null) return const SizedBox();
    
    double val = (moyenne is num) ? moyenne.toDouble() : double.tryParse(moyenne.toString()) ?? 0;
    String mention = '';
    Color color = Colors.white;

    if (val >= 16) {
      mention = 'Très Bien';
      color = Colors.greenAccent;
    } else if (val >= 14) {
      mention = 'Bien';
      color = Colors.blueAccent;
    } else if (val >= 12) {
      mention = 'Assez Bien';
      color = Colors.yellowAccent;
    } else if (val >= 10) {
      mention = 'Passable';
      color = Colors.orangeAccent;
    } else {
      mention = 'Insuffisant';
      color = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Text(
        mention,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildStatTile(theme, 'Rang', '${_bulletin!['rang'] ?? '-'}${_bulletin!['effectif_classe'] != null ? '/${_bulletin!['effectif_classe']}' : ''}', Icons.emoji_events_outlined, Colors.amber),
        _buildStatTile(theme, 'Classe', '${_bulletin!['moyenne_classe'] ?? '-'}/20', Icons.groups_outlined, Colors.blue),
        _buildStatTile(theme, 'Période', _bulletin!['periode'] ?? '-', Icons.calendar_today_outlined, Colors.green),
        _buildStatTile(theme, 'Écart', '${_bulletin!['ecart_classe'] ?? '0.00'}', Icons.show_chart_outlined, Colors.purple),
      ],
    );
  }

  Widget _buildStatTile(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppreciationSection(ThemeData theme) {
    final appreciation = _bulletin!['appreciation'];
    if (appreciation == null || appreciation.toString().isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.comment_outlined, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Text(
                'APPRÉCIATION GÉNÉRALE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.orange,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"$appreciation"',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesHeader(ThemeData theme) {
    return Row(
      children: [
        Text(
          'Détails des Notes',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${(_bulletin!['notes'] as List?)?.length ?? 0} Matìères',
            style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesList(ThemeData theme) {
    final notes = _bulletin!['notes'] as List?;
    if (notes == null || notes.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Aucune note détaillée disponible.'),
        )),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final note = notes[index];
            return _buildNoteItem(theme, note);
          },
          childCount: notes.length,
        ),
      ),
    );
  }

  Widget _buildNoteItem(ThemeData theme, dynamic note) {
    final double? val = (note['note'] is num) ? (note['note'] as num).toDouble() : double.tryParse(note['note']?.toString() ?? '0');
    Color color = Colors.blue;
    if (val != null) {
      if (val >= 15) color = Colors.green;
      else if (val >= 10) color = Colors.orange;
      else color = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${note['coefficient'] ?? 1}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note['matiere_nom'] ?? note['nom'] ?? 'Matière inconnue',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                if (note['appreciation'] != null)
                  Text(
                    note['appreciation'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${val?.toStringAsFixed(1) ?? 'N/A'}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
