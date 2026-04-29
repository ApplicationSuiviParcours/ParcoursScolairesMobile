import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/eleve/providers/eleve_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class EmploiScreen extends StatefulWidget {
  final int? childId;
  const EmploiScreen({super.key, this.childId});

  @override
  State<EmploiScreen> createState() => _EmploiScreenState();
}

class _EmploiScreenState extends State<EmploiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    Future.microtask(() {
      if (!mounted) return;
      context.read<EleveProvider>().loadEmploi(childId: widget.childId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eleveProvider = context.watch<EleveProvider>();
    final allEmploi = eleveProvider.dashboardData?['emploi'] as List? ?? [];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emploi du Temps'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 4,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: _jours.map((j) => Tab(text: j)).toList(),
        ),
      ),
      body: eleveProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : eleveProvider.error != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Erreur: ${eleveProvider.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                ))
              : TabBarView(
              controller: _tabController,
              children: List.generate(5, (dayIndex) {
                final dayNum = dayIndex + 1;
                final dayEmploi = allEmploi.where((e) => e['jour'] == dayNum).toList();
                
                if (dayEmploi.isEmpty) {
                  return _buildEmptyState(theme, _jours[dayIndex]);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  itemCount: dayEmploi.length,
                  itemBuilder: (context, index) {
                    final e = dayEmploi[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time indicators
                          SizedBox(
                            width: 65,
                            child: Column(
                              children: [
                                Text(
                                  e['heure_debut'].toString().substring(0, 5),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w900, 
                                    fontSize: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Container(
                                  height: 40,
                                  width: 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [theme.colorScheme.primary, Colors.grey.withOpacity(0.2)],
                                    ),
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                ),
                                Text(
                                  e['heure_fin'].toString().substring(0, 5),
                                  style: GoogleFonts.inter(
                                    color: Colors.grey[500], 
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Course Card
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.cardTheme.color,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey.withOpacity(0.05), width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e['matiere']?['nom'] ?? 'Matière',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${e['enseignant']?['nom']} ${e['enseignant']?['prenom']}',
                                          style: GoogleFonts.inter(
                                            color: Colors.grey[600], 
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_on_outlined, size: 12, color: theme.colorScheme.primary),
                                            const SizedBox(width: 4),
                                            Text(
                                              'SALLE: ${e['salle'] ?? 'TBA'}',
                                              style: GoogleFonts.inter(
                                                color: theme.colorScheme.primary,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String jour) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_available_rounded, size: 64, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          Text(
            'Journée libre !',
            style: theme.textTheme.headlineMedium?.copyWith(color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucun cours programmé pour ce $jour.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

