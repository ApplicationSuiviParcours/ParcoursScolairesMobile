import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/eleve/providers/eleve_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BulletinsScreen extends StatefulWidget {
  final int? childId;
  const BulletinsScreen({super.key, this.childId});

  @override
  State<BulletinsScreen> createState() => _BulletinsScreenState();
}

class _BulletinsScreenState extends State<BulletinsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<EleveProvider>().loadBulletins(childId: widget.childId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final eleveProvider = context.watch<EleveProvider>();
    final bulletins = eleveProvider.bulletins;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : Colors.black87;

    int totalBulletins = bulletins.length;
    double globalAverage = 0;
    if (totalBulletins > 0) {
      double sum = 0;
      for (var b in bulletins) {
        sum += double.tryParse(b['moyenne_generale']?.toString() ?? '0') ?? 0;
      }
      globalAverage = sum / totalBulletins;
    }

    String trendText = '';
    if (totalBulletins > 1) {
      double latest = double.tryParse(bulletins[0]['moyenne_generale']?.toString() ?? '0') ?? 0;
      double previous = double.tryParse(bulletins[1]['moyenne_generale']?.toString() ?? '0') ?? 0;
      double diff = latest - previous;
      if (diff >= 0) {
        trendText = '+${diff.toStringAsFixed(1)} par rapport au précédent bulletin';
      } else {
        trendText = '${diff.toStringAsFixed(1)} par rapport au précédent bulletin';
      }
    } else {
      trendText = 'Premier bulletin disponible';
    }

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
          'Mes Bulletins',
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
              : bulletins.isEmpty
                  ? _buildEmptyState(theme)
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: _buildOverviewCard(totalBulletins, globalAverage, trendText, isDark),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final bulletin = bulletins[index];
                            return _buildBulletinItem(bulletin, isDark);
                          },
                          childCount: bulletins.length,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32, top: 8),
                        child: _buildBottomInfo(isDark),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildOverviewCard(int total, double average, String trendText, bool isDark) {
    String mention = '';
    Color mentionColor = Colors.white;
    if (average >= 14) { mention = 'Très bien'; mentionColor = const Color(0xFF10B981); }
    else if (average >= 12) { mention = 'Bien'; mentionColor = const Color(0xFFF59E0B); }
    else if (average >= 10) { mention = 'Passable'; mentionColor = const Color(0xFFF59E0B); }
    else { mention = 'Insuffisant'; mentionColor = const Color(0xFFEF4444); }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.grading_rounded, color: Color(0xFF8B5CF6), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Résumé des bulletins', style: GoogleFonts.inter(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('$total', style: GoogleFonts.poppins(color: const Color(0xFF6366F1), fontSize: 28, fontWeight: FontWeight.bold, height: 1.1)),
                      Text('bulletins disponibles', style: GoogleFonts.inter(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
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
                      value: average / 20,
                      strokeWidth: 6,
                      color: const Color(0xFF8B5CF6),
                      backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(average.toStringAsFixed(1), style: GoogleFonts.poppins(color: const Color(0xFF6366F1), fontSize: 16, fontWeight: FontWeight.bold, height: 1)),
                      Text('/20', style: GoogleFonts.inter(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 9, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Moyenne générale', style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black87, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(mention, style: GoogleFonts.inter(color: mentionColor, fontSize: 10, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(trendText.startsWith('+') ? Icons.trending_up : Icons.trending_flat, color: const Color(0xFF8B5CF6), size: 12),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(trendText, style: GoogleFonts.inter(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 8, fontWeight: FontWeight.w500), maxLines: 2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletinItem(dynamic bulletin, bool isDark) {
    final double? val = double.tryParse(bulletin['moyenne_generale']?.toString() ?? '0');
    
    String badgeText = 'Passable';
    Color badgeColor = const Color(0xFFF59E0B);
    Color mainPinkColor = const Color(0xFFE11D48);

    if (val != null) {
      if (val >= 14) { badgeText = 'Très bien'; badgeColor = const Color(0xFF10B981); }
      else if (val >= 12) { badgeText = 'Bien'; badgeColor = const Color(0xFFF59E0B); }
      else if (val < 10) { badgeText = 'Insuffisant'; badgeColor = const Color(0xFFEF4444); }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (widget.childId != null) {
              context.push('/parent/enfant/${widget.childId}/bulletins/${bulletin['id']}');
            } else {
              context.push('/eleve/bulletins/${bulletin['id']}');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: mainPinkColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.grading_rounded, color: mainPinkColor, size: 32),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bulletin['periode'] ?? 'Bulletin',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15, color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 12, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            'Période ${bulletin['periode'] ?? 'en cours'}',
                            style: GoogleFonts.inter(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: mainPinkColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up_rounded, color: mainPinkColor, size: 10),
                            const SizedBox(width: 4),
                            Text('Moyenne générale', style: GoogleFonts.inter(color: mainPinkColor, fontSize: 9, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            val?.toStringAsFixed(1) ?? '-',
                            style: GoogleFonts.poppins(color: mainPinkColor, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' / 20',
                            style: GoogleFonts.inter(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(badgeText, style: GoogleFonts.inter(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le téléchargement sera disponible bientôt.')));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.download_rounded, color: Color(0xFF6366F1), size: 20),
                            ),
                            const SizedBox(height: 4),
                            Text('Télécharger', style: GoogleFonts.inter(color: const Color(0xFF6366F1), fontSize: 9, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: isDark ? Colors.grey[500] : Colors.grey[400], size: 20),
              ],
            ),
          ),
        ),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'À propos des bulletins',
                  style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black87, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Les bulletins sont disponibles à la fin de chaque période d\'évaluation.',
                  style: GoogleFonts.inter(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500),
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
            child: Icon(Icons.picture_as_pdf_outlined, size: 64, color: Colors.grey.withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun bulletin',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos bulletins apparaîtront ici lorsqu\'ils seront publiés.',
            style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.grey[500] : Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
