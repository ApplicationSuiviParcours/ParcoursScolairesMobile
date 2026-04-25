import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/features/eleve/providers/eleve_provider.dart';
import 'package:gestparc/shared/widgets/stat_card.dart';
import 'package:gestparc/shared/widgets/app_drawer.dart';
import 'package:gestparc/core/utils/image_utils.dart';
import 'package:gestparc/core/theme/theme_provider.dart';
import 'package:go_router/go_router.dart';

class EleveDashboardScreen extends StatefulWidget {
  const EleveDashboardScreen({super.key});

  @override
  State<EleveDashboardScreen> createState() => _EleveDashboardScreenState();
}

class _EleveDashboardScreenState extends State<EleveDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    await context.read<EleveProvider>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final eleveProvider = context.watch<EleveProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardData = eleveProvider.dashboardData;
    
    // Improved class detection
    final eleve = dashboardData?['eleve'] ?? user?['profile'];
    final classe = dashboardData?['classe'] ?? eleve?['classe_actuelle'] ?? eleve?['inscription_active']?['classe'];
    
    final photoUrl = ImageUtils.getAbsoluteUrl(user?['photo_url']);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            _buildHeader(context, user, colorScheme, photoUrl, themeProvider),

            // Class Information Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: _buildClassInfo(classe, theme, eleveProvider),
              ),
            ),

            // Modules Grid (Replaced Stats)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              sliver: SliverToBoxAdapter(
                child: _buildModuleGrid(context, colorScheme),
              ),
            ),

            // Recent Activities Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notes Récentes', style: theme.textTheme.headlineMedium),
                    TextButton(
                      onPressed: () => context.push('/eleve/notes'),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Notes List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: eleveProvider.isLoading
                  ? _buildNotesSkeleton()
                  : _buildNotesList(dashboardData?['recent']?['notes'] ?? []),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, ColorScheme colorScheme, String photoUrl, ThemeProvider themeProvider) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: colorScheme.primary,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: Colors.white,
          ),
          onPressed: () => themeProvider.toggleTheme(),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          onPressed: () => context.push('/notifications'),
        ),
        _buildProfileAvatar(context, photoUrl),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary, colorScheme.secondary],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 110, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MA SCOLARITÉ',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 4),
                Text(
                  'Salut, ${user?['name']?.split(' ')[0] ?? 'Élève'} 👋',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bienvenue sur GEST\'PARC',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, String photoUrl) {
    final user = context.watch<AuthProvider>().user;
    final initials = user?['initials'] ?? '?';

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => context.push('/profile'),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white24,
          child: ClipOval(
            child: photoUrl.isNotEmpty
                ? Image.network(
                    photoUrl,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                  )
                : Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
        ),
      ),
    );
  }

  Widget _buildClassInfo(dynamic classe, ThemeData theme, EleveProvider eleveProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.04 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.school_rounded, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MA CLASSE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary, letterSpacing: 1)),
                Text(
                  classe?['nom_complet'] ?? classe?['nom'] ?? (eleveProvider.isLoading ? 'Chargement...' : 'Non assigné'), 
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (classe != null) ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              (classe != null) ? 'ACTIF' : 'INACTIF',
              style: TextStyle(
                color: (classe != null) ? Colors.green : Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleGrid(BuildContext context, ColorScheme colorScheme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildModuleCard(context, 'Mes Notes', Icons.assignment_rounded, const Color(0xFF6366F1), '/eleve/notes'),
        _buildModuleCard(context, 'Mes Absences', Icons.event_busy_rounded, const Color(0xFFF43F5E), '/eleve/absences'),
        _buildModuleCard(context, 'Mes Bulletins', Icons.folder_shared_rounded, const Color(0xFFF59E0B), '/eleve/bulletins'),
        _buildModuleCard(context, 'Emploi du Temps', Icons.calendar_today_rounded, const Color(0xFF10B981), '/eleve/emploi'),
      ],
    );
  }

  Widget _buildModuleCard(BuildContext context, String title, IconData icon, Color color, String route) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.05 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(isDark ? 0.1 : 0.05),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push(route),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Consulter',
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList(List<dynamic> notes) {
    if (notes.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: Text('Aucune note récente')),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final note = notes[index];
          final color = (note['note'] as num) >= 10 ? Colors.green : Colors.red;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Center(child: Text('${note['note']}', style: TextStyle(color: color, fontWeight: FontWeight.w900))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note['evaluation']?['matiere']?['nom'] ?? 'Matière', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(note['evaluation']?['titre'] ?? 'Évaluation', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Text(note['date'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          );
        },
        childCount: notes.length,
      ),
    );
  }

  Widget _buildNotesSkeleton() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 70,
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        ),
        childCount: 3,
      ),
    );
  }

  Widget _buildStatsSkeleton() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: List.generate(4, (i) => Container(decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(24)))),
    );
  }
}
