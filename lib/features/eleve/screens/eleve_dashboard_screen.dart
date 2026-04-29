import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/auth/providers/auth_provider.dart';
import 'package:gestparc/features/eleve/providers/eleve_provider.dart';
import 'package:gestparc/features/notifications/providers/notification_provider.dart';
import 'package:gestparc/shared/widgets/app_drawer.dart';
import 'package:gestparc/core/utils/image_utils.dart';
import 'package:gestparc/core/theme/theme_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert' as dart_convert;

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
    await Future.wait([
      context.read<EleveProvider>().loadDashboard(),
      context.read<NotificationProvider>().loadNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final eleveProvider = context.watch<EleveProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardData = eleveProvider.dashboardData;
    
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
            _buildHeader(context, user, photoUrl, themeProvider),

            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(theme, 'Ma Situation', null),
                    const SizedBox(height: 16),
                    _buildClassInfo(classe, theme, eleveProvider),
                    const SizedBox(height: 32),
                    
                    _buildSectionHeader(theme, 'Mes Services', 'Accès rapide'),
                    const SizedBox(height: 16),
                    _buildModuleGrid(context, colorScheme),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String? subtitle, {String? actionLabel, VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle != null)
              Text(
                subtitle.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
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
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              actionLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, String? photoData, ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final name = user?['name']?.split(' ')[0] ?? 'Élève';

    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: colorScheme.primary,
      leading: IconButton(
        icon: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          radius: 18,
          child: const Icon(Icons.menu_rounded, color: Colors.white, size: 18),
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
                            border: Border.all(color: theme.colorScheme.primary, width: 1),
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
        _buildRobustAvatar(context, user, photoData, 18),
        const SizedBox(width: 16),
      ],
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
            // Décorations simplifiées
            Positioned(
              top: -30,
              right: -30,
              child: Icon(Icons.circle, size: 150, color: Colors.white.withOpacity(0.05)),
            ),
            Positioned(
              bottom: 10,
              left: -20,
              child: Icon(Icons.school_rounded, size: 100, color: Colors.white.withOpacity(0.05)),
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
                          'PORTAIL ÉLÈVE',
                          style: GoogleFonts.inter(
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
                    'Salut, $name 👋',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Voici le résumé de votre scolarité.',
                    style: GoogleFonts.inter(
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

  Widget _buildRobustAvatar(BuildContext context, dynamic user, String? photoData, double radius) {
    final String initialString = user?['initials']?.toString() ?? user?['name']?[0]?.toUpperCase() ?? '?';
    final initials = initialString.trim().isNotEmpty ? initialString : '?';

    Widget imageWidget;
    
    if (photoData != null && photoData.isNotEmpty) {
      if (photoData.startsWith('data:image') || photoData.length > 500) {
        // Decode Base64 string safely
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
        // Load from network URL
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
    );
  }

  Widget _buildFallbackAvatar(String initials) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildClassInfo(dynamic classe, ThemeData theme, EleveProvider eleveProvider) {
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
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.05),
          width: 1.5,
        ),
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
                  style: GoogleFonts.inter(
                    fontSize: 10, 
                    fontWeight: FontWeight.w900, 
                    color: theme.colorScheme.primary, 
                    letterSpacing: 1.5
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  classe?['nom_complet'] ?? classe?['nom'] ?? (eleveProvider.isLoading ? 'Chargement...' : 'Non assigné'), 
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: (classe != null) ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: (classe != null) ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  (classe != null) ? 'INSCRIT' : 'INACTIF',
                  style: GoogleFonts.inter(
                    color: (classe != null) ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
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
      childAspectRatio: 1.15,
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const Spacer(),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Consulter',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 10, color: color),
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

