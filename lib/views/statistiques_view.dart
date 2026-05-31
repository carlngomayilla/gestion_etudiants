import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/avatar_couleur.dart';
import '../viewmodels/etudiant_viewmodel.dart';

/// VIEW — Écran de statistiques : répartition des étudiants.
class StatistiquesView extends StatelessWidget {
  const StatistiquesView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EtudiantViewModel>();
    final parFiliere = vm.statistiquesParFiliere;
    final parNiveau = vm.statistiquesParNiveau;
    final total = vm.total;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: total == 0
          ? const Center(child: Text('Aucune donnée à afficher.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Carte(
                  titre: 'Total',
                  child: Text(
                    '$total étudiant(s)',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 16),
                _Carte(
                  titre: 'Par filière',
                  child: Column(
                    children: [
                      for (final e in parFiliere.entries)
                        _Barre(
                          label: e.key,
                          valeur: e.value,
                          total: total,
                          couleur: couleurDepuisTexte(e.key),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Carte(
                  titre: 'Par niveau',
                  child: Column(
                    children: [
                      for (final e in parNiveau.entries)
                        _Barre(
                          label: e.key,
                          valeur: e.value,
                          total: total,
                          couleur: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _Carte extends StatelessWidget {
  final String titre;
  final Widget child;

  const _Carte({required this.titre, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titre,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Une barre de progression horizontale « label … valeur ».
class _Barre extends StatelessWidget {
  final String label;
  final int valeur;
  final int total;
  final Color couleur;

  const _Barre({
    required this.label,
    required this.valeur,
    required this.total,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : valeur / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                '$valeur  (${(ratio * 100).round()} %)',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: couleur.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(couleur),
            ),
          ),
        ],
      ),
    );
  }
}
