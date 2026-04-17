import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/enseignant/providers/enseignant_provider.dart';
import 'package:go_router/go_router.dart';

class EvaluationsScreen extends StatefulWidget {
  const EvaluationsScreen({super.key});

  @override
  State<EvaluationsScreen> createState() => _EvaluationsScreenState();
}

class _EvaluationsScreenState extends State<EvaluationsScreen> {
  bool _isLoading = true;
  List<dynamic> _evaluations = [];
  Map<String, dynamic>? _selectedAssignment;

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  Future<void> _loadEvaluations() async {
    final ep = context.read<EnseignantProvider>();
    setState(() => _isLoading = true);
    try {
      final resp = await ep.loadEvaluations(
        classeId: _selectedAssignment?['classe_id'],
      );
      if (mounted) {
        setState(() {
          _evaluations = resp['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ep = context.watch<EnseignantProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mes Évaluations', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color(0xFFEA580C)),
            onPressed: () => context.push('/enseignant/evaluations/new').then((_) => _loadEvaluations()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Tout'),
                    selected: _selectedAssignment == null,
                    onSelected: (val) {
                      setState(() => _selectedAssignment = null);
                      _loadEvaluations();
                    },
                    selectedColor: const Color(0xFFEA580C).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFFEA580C),
                  ),
                  const SizedBox(width: 8),
                  ...ep.assignments.map((assignment) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(assignment['classe_nom']),
                        selected: _selectedAssignment == assignment,
                        onSelected: (val) {
                          setState(() => _selectedAssignment = val ? assignment : null);
                          _loadEvaluations();
                        },
                        selectedColor: const Color(0xFFEA580C).withValues(alpha: 0.2),
                        checkmarkColor: const Color(0xFFEA580C),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _evaluations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _evaluations.length,
                    itemBuilder: (context, index) {
                      final eval = _evaluations[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA580C).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.assignment_outlined, color: Color(0xFFEA580C)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    eval['nom'] ?? 'Évaluation',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    '${eval['matiere_classe']?['classe']?['nom']} - ${eval['date_evaluation']}',
                                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Coeff: ${eval['coefficient']}',
                                    style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  eval['periode'] ?? '',
                                  style: const TextStyle(color: Colors.black38, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Aucune évaluation trouvée', style: TextStyle(color: Colors.black38, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => context.push('/enseignant/evaluations/new'),
            icon: const Icon(Icons.add),
            label: const Text('Programmer maintenant'),
          ),
        ],
      ),
    );
  }
}
