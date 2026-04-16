import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/enseignant/providers/enseignant_provider.dart';
import 'package:go_router/go_router.dart';

class SaisieNotesScreen extends StatefulWidget {
  const SaisieNotesScreen({super.key});

  @override
  State<SaisieNotesScreen> createState() => _SaisieNotesScreenState();
}

class _SaisieNotesScreenState extends State<SaisieNotesScreen> {
  bool _isLoading = true;
  List<dynamic> _evaluations = [];
  Map<String, dynamic>? _selectedEvaluation;
  List<dynamic> _eleves = [];
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final ep = context.read<EnseignantProvider>();
    final classeId = GoRouterState.of(context).pathParameters['classeId'];
    
    if (classeId != null) {
      try {
        final evResp = await ep.loadEvaluations(classeId: int.parse(classeId));
        final clResp = await ep.loadClasseEleves(int.parse(classeId));
        
        if (mounted) {
          setState(() {
            _evaluations = evResp['data'] ?? [];
            _eleves = clResp['eleves'] ?? [];
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveNotes() async {
    if (_selectedEvaluation == null) return;
    
    final List<Map<String, dynamic>> notesData = [];
    _controllers.forEach((eleveId, controller) {
      if (controller.text.isNotEmpty) {
        notesData.add({
          'eleve_id': eleveId,
          'note': double.tryParse(controller.text.replaceAll(',', '.')) ?? 0.0,
        });
      }
    });

    if (notesData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucune note à enregistrer.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<EnseignantProvider>().saveNotes(_selectedEvaluation!['id'], notesData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notes enregistrées avec succès.')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Saisie des Notes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          if (_selectedEvaluation != null)
            TextButton.icon(
              onPressed: _saveNotes,
              icon: const Icon(Icons.save_rounded, color: Color(0xFF4F46E5)),
              label: const Text('Sauver', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Evaluation Selector
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  isExpanded: true,
                  hint: const Text('Sélectionner une évaluation'),
                  value: _selectedEvaluation,
                  items: _evaluations.map((ev) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: ev,
                      child: Text('${ev['nom']} (${ev['date_evaluation']})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedEvaluation = val);
                  },
                ),
              ),
            ),
          ),

          if (_selectedEvaluation == null)
            const Expanded(child: Center(child: Text('Veuillez d\'abord choisir une évaluation.')))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _eleves.length,
                itemBuilder: (context, index) {
                  final eleve = _eleves[index];
                  final controller = _controllers.putIfAbsent(eleve['id'], () => TextEditingController());
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('${eleve['prenom']} ${eleve['nom']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0.0',
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('/20', style: TextStyle(color: Colors.black45)),
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
}
