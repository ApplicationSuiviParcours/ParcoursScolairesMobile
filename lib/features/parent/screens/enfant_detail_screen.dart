import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/parent/providers/parent_provider.dart';
import 'package:gestparc/features/notifications/providers/notification_provider.dart';
import 'package:go_router/go_router.dart';

class EnfantDetailScreen extends StatefulWidget {
  final int? enfantId;
  const EnfantDetailScreen({super.key, this.enfantId});

  @override
  State<EnfantDetailScreen> createState() => _EnfantDetailScreenState();
}

class _EnfantDetailScreenState extends State<EnfantDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final parentProvider = context.watch<ParentProvider>();
    final enfant = parentProvider.selectedEnfant;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (enfant == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(child: Text('Aucun enfant sélectionné.')),
      );
    }

    final stats = enfant['stats'];
    final name = enfant['prenom'] ?? 'Enfant';
    final classeName = enfant['inscription_active']?['classe']?['nom_complet'] ?? enfant['inscription_active']?['classe']?['nom'] ?? 'Classe inconnue';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          _buildHeader(context, enfant, name, colorScheme),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClassInfo(classeName, theme),
                  const SizedBox(height: 32),
                  Text(
                    'Résumé des Performances',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsGrid(context, stats),
                ],
              ),
            ),
          ),

          // Performance par Matière
          if (stats?['moyennes_par_matiere'] != null && (stats['moyennes_par_matiere'] as List).isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance par Matière',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: (stats?['moyennes_par_matiere'] as List).take(5).map<Widget>((m) {
                          final double moyenne = (m['moyenne'] as num).toDouble();
                          final color = moyenne >= 14 ? Colors.green : (moyenne >= 10 ? Colors.orange : Colors.red);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(m['nom'], style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isDark ? Colors.white70 : Colors.black87)),
                                    Text('$moyenne/20', style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 15)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: moyenne / 20,
                                    backgroundColor: color.withOpacity(0.15),
                                    valueColor: AlwaysStoppedAnimation<Color>(color),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic enfant, String name, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: colorScheme.primary,
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            final count = notificationProvider.unreadCount;
            return IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                radius: 18,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_rounded, color: Colors.white, size: 18),
                    if (count > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colorScheme.primary, width: 1),
                          ),
                          constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                          child: Text(
                            count > 9 ? '9+' : count.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              onPressed: () => context.push('/notifications'),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      leading: IconButton(
        icon: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          radius: 18,
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary, colorScheme.secondary ?? colorScheme.primaryContainer],
                ),
              ),
            ),
            Positioned(
              top: -30,
              right: -30,
              child: Icon(Icons.circle, size: 150, color: Colors.white.withOpacity(0.05)),
            ),
            Positioned(
              bottom: 10,
              left: -20,
              child: Icon(Icons.face_retouching_natural_rounded, size: 100, color: Colors.white.withOpacity(0.05)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'SUIVI INDIVIDUEL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Profil de $name 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Suivez ses performances scolaires.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassInfo(String classeName, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.05), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary.withOpacity(0.2), theme.colorScheme.primary.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.school_rounded, color: theme.colorScheme.primary, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CLASSE ACTUELLE', 
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.w900, 
                    color: theme.colorScheme.primary, 
                    letterSpacing: 1.5
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  classeName, 
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, dynamic stats) {
    final enfantId = context.read<ParentProvider>().selectedEnfant?['id'];
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildModuleCard(
          context, 
          'Mes Notes', 
          '${stats?['moyenne_generale'] ?? stats?['moyenne'] ?? '0.00'}/20', 
          Icons.assignment_rounded, 
          const Color(0xFF6366F1),
          '/parent/enfant/$enfantId/notes'
        ),
        _buildModuleCard(
          context, 
          'Mes Absences', 
          '${stats?['total_absences'] ?? stats?['absences'] ?? '0'}', 
          Icons.event_busy_rounded, 
          const Color(0xFFF43F5E),
          '/parent/enfant/$enfantId/absences'
        ),
        _buildModuleCard(
          context, 
          'Mes Bulletins', 
          (stats?['total_bulletins'] != null && stats?['total_bulletins'] > 0) 
            ? '${stats?['total_bulletins']} bulletin(s)' 
            : (stats?['bulletins'] != null && stats?['bulletins'] > 0)
              ? '${stats?['bulletins']} bulletin(s)'
              : 'Aucun', 
          Icons.folder_shared_rounded, 
          const Color(0xFFF59E0B),
          '/parent/enfant/$enfantId/bulletins'
        ),
        _buildModuleCard(
          context, 
          'Emploi du Temps', 
          'Consulter', 
          Icons.calendar_today_rounded, 
          const Color(0xFF10B981),
          '/parent/enfant/$enfantId/emploi'
        ),
      ],
    );
  }

  Widget _buildModuleCard(BuildContext context, String title, String value, IconData icon, Color color, String route) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.1 : 0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(isDark ? 0.15 : 0.08),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => context.push(route),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: -0.5,
                        fontSize: value.length > 10 ? 14 : 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

