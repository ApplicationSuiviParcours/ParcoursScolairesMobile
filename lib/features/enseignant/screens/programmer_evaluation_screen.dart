import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestparc/features/enseignant/providers/enseignant_provider.dart';
import 'package:go_router/go_router.dart';

class ProgrammerEvaluationScreen extends StatefulWidget {
  const ProgrammerEvaluationScreen({super.key});

  @override
  State<ProgrammerEvaluationScreen> createState() => _ProgrammerEvaluationScreenState();
}

class _ProgrammerEvaluationScreenState extends State<ProgrammerEvaluationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _dateController = TextEditingController();
  final _coeffController = TextEditingController(text: '1');
  final _descController = TextEditingController();
  
  String? _selectedPeriode;
  Map<String, dynamic>? _selectedClasse;
  bool _isLoading = false;

  final List<String> _periodes = ['trimestre1', 'trimestre2', 'trimestre3'];

  @override
  Widget build(BuildContext context) {
    final ep = context.watch<EnseignantProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Programmer Évaluation', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nouvelle Évaluation', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Remplissez les détails pour informer les élèves et parents.', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 32),

              // Classe & Matière Selector
              const Text('Classe & Matière', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    isExpanded: true,
                    value: _selectedClasse,
                    hint: const Text('Choisir la classe & matière'),
                    items: ep.assignments.map((a) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: a,
                        child: Text('${a['classe_nom']} - ${a['matiere_nom']}'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedClasse = val),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text('Détails de l\'évaluation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomController,
                decoration: _inputDecoration('Nom de l\'évaluation (ex: Contrôle 1)', Icons.title),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: _inputDecoration('Date', Icons.calendar_today),
                      onTap: _selectDate,
                      validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedPeriode,
                          hint: const Text('Période'),
                          items: _periodes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                          onChanged: (v) => setState(() => _selectedPeriode = v),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _coeffController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Coefficient', Icons.star_outline),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: _inputDecoration('Description / Consignes', Icons.description_outlined),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    shape: RoundedRectangleAction(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enregistrer l\'Évaluation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFFEA580C)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black12)),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _dateController.text = picked.toString().split(' ')[0]);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedClasse == null || _selectedPeriode == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs.')));
       return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<EnseignantProvider>().createEvaluation({
        'matiere_classe_id': _selectedClasse!['matiere_classe_id'],
        'nom': _nomController.text,
        'date_evaluation': _dateController.text,
        'periode': _selectedPeriode,
        'coefficient': double.parse(_coeffController.text),
        'description': _descController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Évaluation programmée !')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}

class RoundedRectangleAction extends OutlinedBorder {
  final BorderRadius borderRadius;
  const RoundedRectangleAction({required this.borderRadius});
  
  @override
  OutlinedBorder copyWith({BorderSide? side}) => this;
  
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
  
  @override
  ShapeBorder scale(double t) => this;
}
