import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/features/parent/providers/parent_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gestparc/shared/widgets/app_drawer.dart';
import 'package:gestparc/core/utils/image_utils.dart';
import 'package:google_fonts/google_fonts.dart';

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
            _buildHeader(context, user, photoUrl),

            // Global Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(theme, 'Aperçu Global', 'Résumé du compte'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard(theme, 'ENFANTS', '${statsGlobal?['total_enfants'] ?? 0}', Icons.people_alt_rounded, const Color(0xFF10B981)),
                        const SizedBox(width: 16),
                        _buildStatCard(theme, 'NOTES', '${statsGlobal?['total_notes'] ?? 0}', Icons.assignment_rounded, const Color(0xFFF59E0B)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader(theme, 'Mes Enfants', 'Suivi personnalisé'),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Children List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.primary.withOpacity(0.7),
            letterSpacing: 1.2,
          ),
        ),
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, String photoUrl) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF059669),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.menu_rounded, color: Colors.white, size: 20),
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        _buildProfileAvatar(context, photoUrl),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                ),
              ),
            ),
            Positioned(
              top: -40,
              right: -40,
              child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.1)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      'ESPACE PARENTAL',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bonjour, ${user?['name']?.split(' ')[0] ?? 'Parent'} 👋',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1),
                  ),
                  Text(
                    'Suivez le parcours de vos enfants.',
                    style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, String photoUrl) {
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 18) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 16),
            Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.05)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1), width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
                      backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty ? Text(enfant['prenom'][0], style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900)) : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${enfant['prenom']} ${enfant['nom']}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            enfant['inscription_active']?['classe']?['nom_complet'] ?? 'N/A', 
                            style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w900)
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildEnfantStat(theme, 'MOYENNE', '${stats?['moyenne_generale'] ?? '0.00'}', theme.colorScheme.primary),
                  _buildEnfantStat(theme, 'ABSENCES', '${stats?['total_absences'] ?? 0}', Colors.redAccent),
                  _buildEnfantStat(theme, 'ÉVALS', '${stats?['total_notes'] ?? 0}', Colors.blueAccent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnfantStat(ThemeData theme, String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSkeletonList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 180,
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(28)),
        ),
        childCount: 2,
      ),
    );
  }
}
