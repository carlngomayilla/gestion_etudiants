import 'package:flutter/material.dart';

import '../models/etudiant.dart';
import '../utils/avatar_couleur.dart';

/// WIDGET réutilisable — Affiche un étudiant sous forme de carte
/// avec avatar coloré, badge de niveau et boutons "Modifier"/"Supprimer".
class EtudiantTile extends StatelessWidget {
  final Etudiant etudiant;
  final VoidCallback onTap;
  final VoidCallback onModifier;
  final VoidCallback onSupprimer;

  const EtudiantTile({
    super.key,
    required this.etudiant,
    required this.onTap,
    required this.onModifier,
    required this.onSupprimer,
  });

  @override
  Widget build(BuildContext context) {
    final couleur = couleurDepuisTexte(etudiant.nomComplet);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: couleur,
                foregroundColor: Colors.white,
                child: Text(
                  etudiant.initiales,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            etudiant.nomComplet,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _BadgeNiveau(niveau: etudiant.niveau),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${etudiant.matricule} • ${etudiant.filiere}',
                      style: TextStyle(color: Colors.grey.shade700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      etudiant.email,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: Colors.blue,
                tooltip: 'Modifier',
                onPressed: onModifier,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                tooltip: 'Supprimer',
                onPressed: onSupprimer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Petite pastille affichant le niveau (L1, M2, …).
class _BadgeNiveau extends StatelessWidget {
  final String niveau;

  const _BadgeNiveau({required this.niveau});

  @override
  Widget build(BuildContext context) {
    final couleur = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        niveau,
        style: TextStyle(
          color: couleur,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
