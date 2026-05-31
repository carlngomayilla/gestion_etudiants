import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/etudiant.dart';
import '../viewmodels/etudiant_viewmodel.dart';

/// VIEW — Formulaire d'ajout ET de modification d'un étudiant.
///
/// Si [etudiant] est null  -> mode AJOUT.
/// Si [etudiant] est fourni -> mode MODIFICATION (champs pré-remplis).
class EtudiantFormView extends StatefulWidget {
  final Etudiant? etudiant;

  const EtudiantFormView({super.key, this.etudiant});

  bool get estModification => etudiant != null;

  @override
  State<EtudiantFormView> createState() => _EtudiantFormViewState();
}

class _EtudiantFormViewState extends State<EtudiantFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nom;
  late final TextEditingController _prenom;
  late final TextEditingController _matricule;
  late final TextEditingController _email;
  late final TextEditingController _filiere;
  late String _niveau;

  @override
  void initState() {
    super.initState();
    final e = widget.etudiant;
    _nom = TextEditingController(text: e?.nom ?? '');
    _prenom = TextEditingController(text: e?.prenom ?? '');
    _matricule = TextEditingController(text: e?.matricule ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _filiere = TextEditingController(text: e?.filiere ?? '');
    _niveau = e?.niveau ?? Etudiant.niveaux.first;
  }

  @override
  void dispose() {
    _nom.dispose();
    _prenom.dispose();
    _matricule.dispose();
    _email.dispose();
    _filiere.dispose();
    super.dispose();
  }

  void _enregistrer() {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<EtudiantViewModel>();

    final String? erreur = widget.estModification
        ? vm.modifier(widget.etudiant!.copyWith(
            nom: _nom.text,
            prenom: _prenom.text,
            matricule: _matricule.text,
            email: _email.text,
            filiere: _filiere.text,
            niveau: _niveau,
          ))
        : vm.ajouter(
            nom: _nom.text,
            prenom: _prenom.text,
            matricule: _matricule.text,
            email: _email.text,
            filiere: _filiere.text,
            niveau: _niveau,
          );

    // En cas d'erreur (ex. matricule déjà utilisé), on reste sur le
    // formulaire et on prévient l'utilisateur.
    if (erreur != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erreur),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    Navigator.of(context).pop();
  }

  String? _obligatoire(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null;

  String? _validerEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Champ obligatoire';
    final regex = RegExp(r'^[\w.\-]+@[\w\-]+\.[a-zA-Z]+$');
    return regex.hasMatch(v.trim()) ? null : 'Email invalide';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.estModification ? 'Modifier l\'étudiant' : 'Ajouter un étudiant',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _champ(_prenom, 'Prénom', Icons.person, _obligatoire,
                capitalisation: TextCapitalization.words),
            _champ(_nom, 'Nom', Icons.person_outline, _obligatoire,
                capitalisation: TextCapitalization.words),
            _champ(
              _matricule,
              'Matricule',
              Icons.badge,
              _obligatoire,
              formatters: [_MajusculesFormatter()],
            ),
            _champ(_email, 'Email', Icons.email, _validerEmail,
                clavier: TextInputType.emailAddress),
            _champ(_filiere, 'Filière', Icons.school, _obligatoire,
                capitalisation: TextCapitalization.words),
            _menuNiveau(),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _enregistrer,
              icon: const Icon(Icons.save),
              label: Text(
                widget.estModification ? 'Enregistrer' : 'Ajouter',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuNiveau() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: _niveau,
        decoration: const InputDecoration(
          labelText: 'Niveau',
          prefixIcon: Icon(Icons.grade),
          border: OutlineInputBorder(),
        ),
        items: [
          for (final n in Etudiant.niveaux)
            DropdownMenuItem(value: n, child: Text(n)),
        ],
        onChanged: (v) => setState(() => _niveau = v ?? _niveau),
      ),
    );
  }

  Widget _champ(
    TextEditingController controller,
    String label,
    IconData icone,
    String? Function(String?) validateur, {
    TextInputType clavier = TextInputType.text,
    TextCapitalization capitalisation = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: clavier,
        textCapitalization: capitalisation,
        inputFormatters: formatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icone),
          border: const OutlineInputBorder(),
        ),
        validator: validateur,
      ),
    );
  }
}

/// Force la saisie en MAJUSCULES (utilisé pour le matricule).
class _MajusculesFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
