import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/features/parent/providers/parent_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gestparc/shared/widgets/app_drawer.dart';
import 'package:gestparc/core/utils/image_utils.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    await context.read<ParentProvider>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final parentProvider = context.watch<ParentProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statsGlobal = parentProvider.statsGlobal;
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
            // Premium AppBar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: colorScheme.primary,
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              actions: [
                _buildAvatar(context, photoUrl),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [const Color(0xFF059669), const Color(0xFF10B981)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 110, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ESPACE PARENTAL',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bonjour, ${user?['name']?.split(' ')[0] ?? 'Parent'} 👋',
                          style: theme.textTheme.displayMedium?.copyWith(color: Colors.white, fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Suivez le parcours de vos enfants',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Global Overview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    _buildSummaryCard(theme, Icons.people_alt_rounded, '${statsGlobal?['total_enfants'] ?? 0} Enfants', const Color(0xFF059669)),
                    const SizedBox(width: 12),
                    _buildSummaryCard(theme, Icons.assignment_rounded, '${statsGlobal?['total_notes'] ?? 0} Notes', Colors.orange),
                  ],
                ),
              ),
            ),

            // Children List Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text('Mes Enfants', style: theme.textTheme.headlineMedium),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: parentProvider.isLoading
                  ? _buildSkeletonList()
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final enfant = parentProvider.enfants[index];
                          final stats = enfant['stats'];
                          final enfantPhoto = ImageUtils.getAbsoluteUrl(enfant['photo']);
                          
                          return _buildEnfantCard(context, theme, enfant, stats, enfantPhoto);
                        },
                        childCount: parentProvider.enfants.length,
                      ),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String photoUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => context.push('/profile'),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white24,
          backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
          child: photoUrl.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnfantCard(BuildContext context, ThemeData theme, dynamic enfant, dynamic stats, String photoUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.04 : 0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          context.read<ParentProvider>().selectEnfant(enfant);
          context.push('/parent/enfant/${enfant['id']}');
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty ? Text( enfant['prenom'][0], style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 20)) : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${enfant['prenom']} ${enfant['nom']}', style: theme.textTheme.titleLarge),
                        Text(enfant['inscription_active']?['classe']?['nom_complet'] ?? enfant['inscription_active']?['classe']?['nom'] ?? 'Classe non définie', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildEnfantStat('Moyenne', '${stats?['moyenne_generale'] ?? '0.00'}', theme.colorScheme.primary),
                  _buildEnfantStat('Absences', '${stats?['total_absences'] ?? 0}', Colors.orange),
                  _buildEnfantStat('Notes', '${stats?['total_notes'] ?? 0}', Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnfantStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSkeletonList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 160,
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
        ),
        childCount: 2,
      ),
    );
  }
}
