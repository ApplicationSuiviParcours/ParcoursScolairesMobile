import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/eleve/providers/eleve_provider.dart';

class EmploiScreen extends StatefulWidget {
  const EmploiScreen({super.key});

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
      context.read<EleveProvider>().loadEmploi();
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Emploi du Temps', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF4F46E5),
          unselectedLabelColor: Colors.black45,
          indicatorColor: const Color(0xFF4F46E5),
          indicatorWeight: 3,
          tabs: _jours.map((j) => Tab(text: j)).toList(),
        ),
      ),
      body: eleveProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: List.generate(5, (dayIndex) {
                final dayNum = dayIndex + 1;
                final dayEmploi = allEmploi.where((e) => e['jour'] == dayNum).toList();
                
                if (dayEmploi.isEmpty) {
                  return const Center(child: Text('Aucun cours ce jour.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: dayEmploi.length,
                  itemBuilder: (context, index) {
                    final e = dayEmploi[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          // Time indicators
                          SizedBox(
                            width: 60,
                            child: Column(
                              children: [
                                Text(
                                  e['heure_debut'].toString().substring(0, 5),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Container(
                                  height: 30,
                                  width: 2,
                                  color: Colors.black12,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                ),
                                Text(
                                  e['heure_fin'].toString().substring(0, 5),
                                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Course Card
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: const Border(
                                  left: BorderSide(color: Color(0xFF4F46E5), width: 4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e['matiere']?['nom'] ?? 'Matière',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_pin_outlined, size: 14, color: Colors.black45),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${e['enseignant']?['nom']} ${e['enseignant']?['prenom']}',
                                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Salle: ${e['salle'] ?? 'TBA'}',
                                          style: const TextStyle(
                                            color: Color(0xFF4F46E5),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
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
}
