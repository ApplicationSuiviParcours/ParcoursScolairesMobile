import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/features/parent/providers/parent_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gestparc/shared/widgets/app_drawer.dart';
import 'package:gestparc/core/utils/image_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestparc/core/theme/theme_provider.dart';
import 'package:gestparc/features/notifications/providers/notification_provider.dart';
import 'dart:convert' as dart_convert;

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
    await Future.wait([
      context.read<ParentProvider>().loadDashboard(),
      context.read<NotificationProvider>().loadNotifications(),
    ]);
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
    final themeProvider = context.watch<ThemeProvider>();
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
                            border: Border.all(color: const Color(0xFF0F172A), width: 1),
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
        IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            radius: 18,
            child: Icon(
              themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          onPressed: () => themeProvider.toggleTheme(),
        ),
        const SizedBox(width: 8),
        _buildRobustAvatar(context, user, photoUrl, 18),
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

  Widget _buildRobustAvatar(BuildContext context, dynamic user, String? photoData, double radius) {
    final String initialString = user?['initials']?.toString() ?? user?['name']?[0]?.toUpperCase() ?? '?';
    final initials = initialString.trim().isNotEmpty ? initialString : '?';

    Widget imageWidget;
    
    if (photoData != null && photoData.isNotEmpty) {
      if (photoData.startsWith('data:image') || photoData.length > 500) {
        try {
          final String base64Str = photoData.contains(',') ? photoData.split(',')[1] : photoData;
          final bytes = dart_convert.base64Decode(base64Str.replaceAll(RegExp(r'\s+'), ''));
          imageWidget = Image.memory(bytes, width: radius * 2, height: radius * 2, fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(initials),
          );
        } catch (e) {
          imageWidget = _buildFallbackAvatar(initials);
        }
      } else if (photoData.startsWith('http')) {
        imageWidget = Image.network(
          photoData,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(initials),
        );
      } else {
        imageWidget = _buildFallbackAvatar(initials);
      }
    } else {
      imageWidget = _buildFallbackAvatar(initials);
    }

    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: ClipOval(child: imageWidget),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(String initials) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
                  _buildEnfantStat(theme, 'MOYENNE', '${stats?['moyenne_generale'] ?? stats?['moyenne'] ?? '0.00'}', theme.colorScheme.primary),
                  _buildEnfantStat(theme, 'ABSENCES', '${stats?['total_absences'] ?? stats?['absences'] ?? 0}', Colors.redAccent),
                  _buildEnfantStat(theme, 'ÉVALS', '${stats?['total_notes'] ?? stats?['total'] ?? 0}', Colors.blueAccent),
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
