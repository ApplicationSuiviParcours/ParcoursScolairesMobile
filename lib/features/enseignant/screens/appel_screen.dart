import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/enseignant/providers/enseignant_provider.dart';
import 'package:go_router/go_router.dart';

class AppelScreen extends StatefulWidget {
  const AppelScreen({super.key});

  @override
  State<AppelScreen> createState() => _AppelScreenState();
}

class _AppelScreenState extends State<AppelScreen> {
  bool _isLoading = true;
  List<dynamic> _eleves = [];
  List<dynamic> _matieres = [];
  Map<String, dynamic>? _selectedMatiere;
  final Set<int> _absents = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final ep = context.read<EnseignantProvider>();
    final classeId = GoRouterState.of(context).pathParameters['classeId'];
    
    if (classeId != null) {
      try {
        final clResp = await ep.loadClasseEleves(int.parse(classeId));
        
        if (mounted) {
          setState(() {
            // Filter assignments for this class
            _matieres = ep.assignments.where((a) => a['classe_id'] == int.parse(classeId)).toList();
            if (_matieres.isNotEmpty) _selectedMatiere = _matieres.first;
            _eleves = clResp['eleves'] ?? [];
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveAppel() async {
    if (_selectedMatiere == null) return;
    
    if (_absents.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun absent sélectionné. L\'appel est déjà complet ?')));
       return;
    }

    final data = {
      'matiere_id': _selectedMatiere!['matiere_id'],
      'date_absence': DateTime.now().toIso8601String().split('T')[0],
      'absences': _absents.map((id) => {
        'eleve_id': id,
        'justifiee': false,
        'commentaire': 'Absent lors de l\'appel mobile'
      }).toList(),
    };

    setState(() => _isLoading = true);
    try {
      await context.read<EnseignantProvider>().saveAbsences(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appel enregistré avec succès.')));
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
        title: const Text('Faire l\'Appel', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          TextButton(
            onPressed: _saveAppel,
            child: const Text('Valider', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Matiere Selection
          Padding(
            padding: const EdgeInsets.all(24),
            child: DropdownButtonFormField<Map<String, dynamic>>(
              decoration: InputDecoration(
                labelText: 'Matière du cours',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              initialValue: _selectedMatiere,
              items: _matieres.map((m) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: m,
                  child: Text(m['nom']),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedMatiere = val),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _eleves.length,
              itemBuilder: (context, index) {
                final eleve = _eleves[index];
                final isAbsent = _absents.contains(eleve['id']);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CheckboxListTile(
                    title: Text('${eleve['prenom']} ${eleve['nom']}'),
                    subtitle: Text(eleve['matricule'] ?? '', style: const TextStyle(fontSize: 10)),
                    secondary: const Icon(Icons.person_outline),
                    value: isAbsent,
                    activeColor: Colors.redAccent,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _absents.add(eleve['id']);
                        } else {
                          _absents.remove(eleve['id']);
                        }
                      });
                    },
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
