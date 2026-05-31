import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/etudiant.dart';
import '../utils/avatar_couleur.dart';
import '../viewmodels/etudiant_viewmodel.dart';
import 'etudiant_form_view.dart';

/// VIEW — Écran de détail d'un étudiant.
///
/// On garde uniquement l'`id` et on relit l'étudiant depuis le ViewModel :
/// l'écran reste ainsi à jour après une modification, et se referme tout seul
/// si l'étudiant est supprimé.
class EtudiantDetailView extends StatelessWidget {
  final String etudiantId;

  const EtudiantDetailView({super.key, required this.etudiantId});

  Future<void> _confirmerSuppression(
    BuildContext context,
    Etudiant etudiant,
  ) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Voulez-vous vraiment supprimer ${etudiant.nomComplet} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirme == true && context.mounted) {
      context.read<EtudiantViewModel>().supprimer(etudiant.id);
      Navigator.of(context).pop(); // ferme le détail
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${etudiant.nomComplet} supprimé(e)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EtudiantViewModel>();
    final etudiant = vm.getById(etudiantId);

    // Si l'étudiant n'existe plus (supprimé), on referme l'écran.
    if (etudiant == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final couleur = couleurDepuisTexte(etudiant.nomComplet);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EtudiantFormView(etudiant: etudiant),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Supprimer',
            onPressed: () => _confirmerSuppression(context, etudiant),
          ),
        ],
      ),
      body: ListView(
        children: [
          _entete(couleur, etudiant),
          const SizedBox(height: 8),
          _ligne(Icons.badge, 'Matricule', etudiant.matricule),
          _ligne(Icons.school, 'Filière', etudiant.filiere),
          _ligne(Icons.grade, 'Niveau', etudiant.niveau),
          _ligne(Icons.email, 'Email', etudiant.email),
          _ligne(Icons.person, 'Prénom', etudiant.prenom),
          _ligne(Icons.person_outline, 'Nom', etudiant.nom),
        ],
      ),
    );
  }

  Widget _entete(Color couleur, Etudiant etudiant) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [couleur, couleur.withValues(alpha: 0.7)],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white,
            foregroundColor: couleur,
            child: Text(
              etudiant.initiales,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            etudiant.nomComplet,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${etudiant.filiere} · ${etudiant.niveau}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _ligne(IconData icone, String label, String valeur) {
    return ListTile(
      leading: Icon(icone),
      title: Text(label, style: const TextStyle(color: Colors.grey)),
      subtitle: Text(
        valeur,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}
