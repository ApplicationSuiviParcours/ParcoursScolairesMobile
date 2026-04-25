import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/eleve/providers/eleve_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AbsencesScreen extends StatefulWidget {
  const AbsencesScreen({super.key});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<EleveProvider>().loadAbsences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eleveProvider = context.watch<EleveProvider>();
    final absences = eleveProvider.absences;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Absences'),
      ),
      body: eleveProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : absences.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  itemCount: absences.length,
                  itemBuilder: (context, index) {
                    final absence = absences[index];
                    final isJustifiee = absence['justifiee'] == true || absence['justifiee'] == 1;
                    final color = isJustifiee ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              isJustifiee ? Icons.verified_rounded : Icons.report_problem_rounded,
                              color: color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  absence['matiere']?['nom'] ?? 'Matière inconnue',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey[500]),
                                    const SizedBox(width: 6),
                                    Text(
                                      absence['date_absence'] ?? 'Date inconnue',
                                      style: GoogleFonts.inter(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isJustifiee ? 'Justifiée' : 'En attente',
                              style: GoogleFonts.inter(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
            child: Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.green.withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          Text(
            'Zéro Absences !',
            style: theme.textTheme.headlineMedium?.copyWith(color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Félicitations, vous avez été présent à tous vos cours.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
